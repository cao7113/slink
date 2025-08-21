defmodule Slink.UserLinks do
  @moduledoc """
  The UserLinks context.
  """

  import Ecto.Query, warn: false
  alias Slink.Repo

  alias Slink.Accounts.Scope
  alias Slink.Links
  alias Slink.Links.Link
  alias Slink.Links.UserLink

  @doc """
  Subscribes to scoped notifications about any user_link changes.

  The broadcasted messages match the pattern:

    * {:created, %UserLink{}}
    * {:updated, %UserLink{}}
    * {:deleted, %UserLink{}}

  """
  def subscribe_user_links(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Slink.PubSub, "user:#{key}:user_links")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Slink.PubSub, "user:#{key}:user_links", message)
  end

  @doc """
  Returns the list of user_links.

  ## Examples

      iex> list_user_links(scope)
      [%UserLink{}, ...]

  """
  def list_user_links(%Scope{} = scope) do
    Repo.all_by(UserLink, user_id: scope.user.id)
  end

  def top_pinned_user_links(%Scope{} = scope, top_limit \\ 10) do
    query =
      from ul in UserLink,
        where: ul.user_id == ^scope.user.id and not is_nil(ul.pin_at),
        order_by: [desc_nulls_last: ul.pin_at, desc: ul.id],
        preload: [:link],
        limit: ^top_limit

    Repo.all(query)
  end

  @doc """
  Gets a single user_link.

  Raises `Ecto.NoResultsError` if the User link does not exist.

  ## Examples

      iex> get_user_link!(scope, 123)
      %UserLink{}

      iex> get_user_link!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_user_link!(%Scope{} = scope, id) do
    Repo.get_by!(UserLink, id: id, user_id: scope.user.id)
  end

  @doc """
  Collects a user_link.

  ## Examples

      iex> collect_user_link(scope, %{field: value})
      {:ok, %UserLink{}}

      iex> collect_user_link(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def collect_user_link(%Scope{} = scope, %Link{} = link),
    do: do_collect_user_link(scope, link, %{})

  def collect_user_link(%Scope{} = scope, %{} = attrs) do
    link_attrs = Map.take(attrs, [:title, :url, :input_tags])

    with {:ok, link} <- Links.get_or_create_link(scope, link_attrs) do
      do_collect_user_link(scope, link, attrs)
    end
  end

  def do_collect_user_link(%Scope{} = scope, %Link{title: title} = link, attrs \\ %{}) do
    ulink_attrs =
      attrs
      |> Map.put(:link_id, link.id)
      |> Map.put_new(:title, title)

    with {:ok, ulink} <- get_or_create_user_link(scope, ulink_attrs) do
      # always add?
      Links.create_link_log(scope, %{link_id: link.id, event: "collected"})

      # put link assoc
      ulink = %{ulink | link: link}
      {:ok, ulink}
    end
  end

  def toggle_favor(%Scope{} = scope, %Link{} = link) do
    with {:ok, ulink} <- collect_user_link(scope, link) do
      attrs =
        if ulink.favor_at do
          %{favor_at: nil}
        else
          %{favor_at: DateTime.utc_now(:second)}
        end

      update_user_link(scope, ulink, attrs)
    end
  end

  def toggle_pin(%Scope{} = scope, %Link{} = link) do
    with {:ok, ulink} <- collect_user_link(scope, link) do
      attrs =
        if ulink.pin_at do
          %{pin_at: nil}
        else
          %{pin_at: DateTime.utc_now(:second)}
        end

      update_user_link(scope, ulink, attrs)
    end
  end

  def update_note(%Scope{} = scope, %Link{} = link, note) do
    with {:ok, ulink} <- collect_user_link(scope, link) do
      attrs = %{note: note}
      update_user_link(scope, ulink, attrs)
    end
  end

  def get_or_create_user_link(
        %Scope{} = scope,
        %{link_id: link_id, title: _title} = attrs
      ) do
    Repo.get_by(UserLink, user_id: scope.user.id, link_id: link_id)
    |> case do
      %UserLink{} = ulink ->
        # update_user_link(scope, ulink, %{
        #   last_visit_at: DateTime.utc_now(:second),
        #   total_visit_times: ulink.total_visit_times + 1
        # })
        {:ok, ulink}

      nil ->
        create_user_link(scope, attrs)
    end
  end

  @doc """
  Creates a user_link.

  ## Examples

      iex> create_user_link(scope, %{field: value})
      {:ok, %UserLink{}}

      iex> create_user_link(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_link(%Scope{} = scope, attrs, insert_opts \\ []) do
    with {:ok, user_link = %UserLink{}} <-
           %UserLink{}
           |> UserLink.changeset(attrs, scope)
           |> Repo.insert(insert_opts) do
      broadcast(scope, {:created, user_link})
      {:ok, user_link}
    end
  end

  @doc """
  Updates a user_link.

  ## Examples

      iex> update_user_link(scope, user_link, %{field: new_value})
      {:ok, %UserLink{}}

      iex> update_user_link(scope, user_link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_link(%Scope{} = scope, %UserLink{} = user_link, attrs) do
    true = user_link.user_id == scope.user.id

    with {:ok, user_link = %UserLink{}} <-
           user_link
           |> UserLink.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, user_link})
      {:ok, user_link}
    end
  end

  @doc """
  Deletes a user_link.

  ## Examples

      iex> delete_user_link(scope, user_link)
      {:ok, %UserLink{}}

      iex> delete_user_link(scope, user_link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_link(%Scope{} = scope, %UserLink{} = user_link) do
    true = user_link.user_id == scope.user.id

    with {:ok, user_link = %UserLink{}} <-
           Repo.delete(user_link) do
      broadcast(scope, {:deleted, user_link})
      {:ok, user_link}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_link changes.

  ## Examples

      iex> change_user_link(scope, user_link)
      %Ecto.Changeset{data: %UserLink{}}

  """
  def change_user_link(%Scope{} = scope, %UserLink{} = user_link, attrs \\ %{}) do
    true = user_link.user_id == scope.user.id

    UserLink.changeset(user_link, attrs, scope)
  end
end
