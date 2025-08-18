#! mix run

alias Slink.Accounts
alias Slink.Accounts.UserToken
# alias Slink.Links
alias Slink.UserLinks

email = "a1@b.c"
email2 = "a2@b.c"
password = "123456123456"
api_token = "dev_api_token---kC6IkpcQRO4VvuVFgszZRnvDDSU"

# mix links.dump
links_data_file = Path.join(__DIR__, "links.json")

## Accounts data

info = %{
  email: email,
  password: password,
  api_token: api_token
}

user = Accounts.get_user_by_email(email)

dev_user =
  if !user do
    user = Accounts.register_confirmed_user_with_password(email, password)

    # create api-token
    api_token
    |> Accounts.fetch_user_by_api_token()
    |> case do
      {:ok, got_user} ->
        if got_user.id != user.id do
          raise "Mismatch user-id #{got_user.id} != #{user.id}"
        end

      :error ->
        secret = api_token |> UserToken.decode_secret_token!()
        Accounts.create_user_api_token_with_secret(user, secret)
    end

    user
  else
    user
  end

IO.puts("dev-user=#{dev_user.id} created with info #{info |> inspect(pretty: true)}!")

Accounts.register_confirmed_user_with_password(email2, password)

user_scope = Accounts.Scope.for_user(dev_user)

## Links data

links =
  links_data_file
  |> File.read!()
  |> Jason.decode!(keys: :atoms)

links
|> Enum.each(fn attrs ->
  attrs = Map.take(attrs, [:title, :url])
  # Links.create_link(user_scope, attrs)
  UserLinks.collect_user_link(user_scope, attrs)
end)

IO.puts("#{Enum.count(links)} links created!")
