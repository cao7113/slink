defmodule Slink.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query, warn: false

  alias Slink.Repo
  alias Slink.Tags.Tag
  alias Slink.Accounts.Scope

  require Logger

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
  def list_tags(%Scope{} = _scope) do
    from(t in Tag, order_by: [desc: t.updated_at, desc: t.id], limit: 100)
    |> Repo.all()
  end

  def search_tags(q, limit \\ 50) when is_binary(q) do
    from(t in Tag)
    |> join(:left, [t], l in assoc(t, :links))
    |> where([t], like(t.name, ^"#{q}%"))
    |> group_by([t], [t.id])
    |> order_by([t], desc: t.updated_at, desc: count(t.id), desc: t.id)
    |> limit(^limit)
    # count maybe not exact(virutal +1)!!! with null left join
    |> select([t], %{t | links_count: count(t.id)})
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

  def get_tag(id), do: Repo.get_by(Tag, id: id)

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

  ## tags input

  # 中英文逗号，分号，顿号
  @tag_seperators ~r/[,，;；、]/u

  # https://hexdocs.pm/ecto/3.13.2/constraints-and-upserts.html
  def filter_and_ensure_tags(input_tags, user_scope) do
    input_tags
    |> parse_tags()
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
    |> check_tag_names_validation()
    |> insert_and_get_all(user_scope)
  end

  def parse_tags(tags) when is_binary(tags), do: tags |> String.split(@tag_seperators)
  def parse_tags(tags) when is_list(tags), do: tags

  def check_tag_names_validation(tag_names) do
    tag_names
    |> Enum.filter(fn name ->
      Tag.check_tag_name(name).valid?
      |> case do
        true ->
          true

        false ->
          Logger.warning("Ignore ivalid tag name: #{inspect(name)}")
          false
      end
    end)
  end

  def insert_and_get_all([], _), do: []

  def insert_and_get_all(names, user_scope) when is_list(names) do
    timestamp = DateTime.utc_now(:second)
    placeholders = %{timestamp: timestamp}

    maps =
      Enum.map(
        names,
        &%{
          name: &1,
          user_id: user_scope.user.id,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      )

    Repo.insert_all(
      Tag,
      maps,
      placeholders: placeholders,
      on_conflict: :nothing
    )

    # todo: fix tags order lost
    Repo.all(from t in Tag, where: t.name in ^names)
  end
end
