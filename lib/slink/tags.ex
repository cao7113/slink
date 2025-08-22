defmodule Slink.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query, warn: false
  alias Slink.Repo

  alias Slink.Tags.Tag
  alias Slink.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any tag changes.

  The broadcasted messages match the pattern:

    * {:created, %Tag{}}
    * {:updated, %Tag{}}
    * {:deleted, %Tag{}}

  """
  def subscribe_tags(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Slink.PubSub, "user:#{key}:tags")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Slink.PubSub, "user:#{key}:tags", message)
  end

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags(scope)
      [%Tag{}, ...]

  """
  def list_tags(%Scope{} = scope) do
    Repo.all_by(Tag, user_id: scope.user.id)
  end

  def list_tags(_) do
    list_tags()
  end

  def list_tags() do
    from(t in Tag, limit: 100, order_by: [desc: t.updated_at, desc: t.id])
    |> Repo.all()
  end

  def tags_string(tags) when is_list(tags) do
    tags |> Enum.map(& &1.name) |> Enum.join(", ")
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(scope, 123)
      %Tag{}

      iex> get_tag!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(%Scope{} = scope, id) do
    Repo.get_by!(Tag, id: id, user_id: scope.user.id)
  end

  def get_tag!(id), do: Repo.get_by!(Tag, id: id)

  def get_by_name(name) when is_binary(name), do: Repo.get_by(Tag, name: name)

  def get_or_create_tag(%Scope{} = scope, name) do
    case Repo.get_by(Tag, name: name) do
      nil -> create_tag(scope, %{name: name})
      tag -> {:ok, tag}
    end
  end

  def upsert_tag(%Scope{} = scope, name) do
    Tag.changeset(%Tag{}, %{name: name}, scope)
    |> Repo.insert(
      on_conflict: {:replace, [:updated_at]},
      # on_conflict: :nothing,
      # https://hexdocs.pm/ecto/3.13.2/Ecto.Repo.html#c:insert/2-upserts
      # Specify read_after_writes: true in your schema for choosing fields that are read from the database after every operation.
      # Or pass returning: true to insert to read all fields back.
      # (Note that it will only read from the database if at least one field is updated).
      returning: true,
      conflict_target: :name
    )
  end

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(scope, %{field: value})
      {:ok, %Tag{}}

      iex> create_tag(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(%Scope{} = scope, attrs) do
    with {:ok, tag = %Tag{}} <-
           %Tag{}
           |> Tag.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, tag})
      {:ok, tag}
    end
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(scope, tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(scope, tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Scope{} = scope, %Tag{} = tag, attrs) do
    true = tag.user_id == scope.user.id

    with {:ok, tag = %Tag{}} <-
           tag
           |> Tag.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, tag})
      {:ok, tag}
    end
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(scope, tag)
      {:ok, %Tag{}}

      iex> delete_tag(scope, tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Scope{} = scope, %Tag{} = tag) do
    true = tag.user_id == scope.user.id

    with {:ok, tag = %Tag{}} <-
           Repo.delete(tag) do
      broadcast(scope, {:deleted, tag})
      {:ok, tag}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(scope, tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Scope{} = scope, %Tag{} = tag, attrs \\ %{}) do
    true = tag.user_id == scope.user.id

    Tag.changeset(tag, attrs, scope)
  end
end
