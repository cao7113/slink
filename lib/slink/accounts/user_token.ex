defmodule Slink.Accounts.UserToken do
  use Ecto.Schema
  use Endon
  import Ecto.Query
  alias Slink.Accounts.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60
  @api_validity_in_days 365

  schema "users_tokens" do
    # NOTE: this is hashed token, not directly used by user, only for verification
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :user, Slink.Accounts.User

    # virtual fields
    field :expired_at, :utc_datetime, virtual: true
    field :token_hex, :string, virtual: true

    timestamps(type: :utc_datetime, updated_at: false)
  end

  ## API Tokens

  @api_token_context "api-token"

  def build_api_token(user) do
    {encoded_token, hashed_token} = encode_api_token()

    {encoded_token,
     %UserToken{
       token: hashed_token,
       context: @api_token_context,
       user_id: user.id
     }}
  end

  def verify_api_token_query(user_api_token) do
    with {:ok, token} <- decode_api_token(user_api_token) do
      query =
        from token in by_token_and_context_query(token, @api_token_context),
          join: user in assoc(token, :user),
          where: token.inserted_at > ago(@api_validity_in_days, "day"),
          select: user

      {:ok, query}
    else
      r ->
        {:error, r}
    end
  end

  @prefix_size 10

  def encode_api_token() do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)
    <<prefix::binary-size(@prefix_size), _rest::binary>> = Base.encode16(hashed_token)
    user_api_token = prefix <> "-" <> Base.url_encode64(token, padding: false)
    {user_api_token, hashed_token}
  end

  def decode_api_token(user_api_token) do
    String.split(user_api_token, "-", parts: 2)
    |> case do
      [_, encoded_token] ->
        {:ok, raw_token} = Base.url_decode64(encoded_token, padding: false)
        hased_token = :crypto.hash(@hash_algorithm, raw_token)
        {:ok, hased_token}

      _ ->
        :invalid_user_api_token
    end
  end

  def api_token_query(token) do
    by_token_and_context_query(token, @api_token_context)
  end

  def list_api_tokens_query(user, mode \\ :all, opts \\ [])
      when mode in [:all, :valid, :invalid] do
    context = @api_token_context
    days = days_for_context(context)

    query =
      from token in UserToken,
        where: [user_id: ^user.id, context: ^context]

    page = opts[:page]

    query =
      if page do
        per_page = opts[:per_page] || 10
        offset = (page - 1) * per_page

        from t in query,
          offset: ^offset,
          limit: ^per_page
      else
        query
      end

    case mode do
      :invalid ->
        from t in query, where: t.inserted_at <= ago(^days, "day")

      :valid ->
        from t in query, where: t.inserted_at > ago(^days, "day")

      _ ->
        query
    end
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)

    {token,
     %UserToken{
       token: token,
       context: "session",
       user_id: user.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  @doc """
  Builds a token and its hash to be delivered to the user's email.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  def enrich(%{inserted_at: inserted_at, token: token, context: ctx} = ut) do
    %{
      ut
      | expired_at: inserted_at |> DateTime.add(days_for_context(ctx), :day),
        token_hex: Base.encode16(token) |> String.slice(0..9)
    }
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within a certain period, depending on the
  context. The default contexts supported by this function are either
  "confirm", for account confirmation emails, and "reset_password",
  for resetting the password. For verifying requests to change the email,
  see `verify_change_email_token_query/2`.
  """
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("api-token"), do: @api_validity_in_days
  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  This is used to validate requests to change the user
  email. It is different from `verify_email_token_query/2` precisely because
  `verify_email_token_query/2` validates the email has not changed, which is
  the starting point by this function.

  The given token is valid if it matches its hashed counterpart in the
  database and if it has not expired (after @change_email_validity_in_days).
  The context must always start with "change:".
  """
  def verify_change_email_token_query(token, "change:" <> _ = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Returns the token struct for the given token value and context.
  """
  def by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given user for the given contexts.
  """
  def by_user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  def by_user_and_contexts_query(user, [_ | _] = contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end
end
