defmodule Slink.Links.Link do
  use Endon
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Slink.Repo
  alias Slink.Tags.Tag
  alias Slink.Links.LinkTag

  @default_limit 20

  # https://hexdocs.pm/flop/Flop.Schema.html#module-usage
  @derive {
    Flop.Schema,
    max_limit: 200,
    default_limit: @default_limit,
    filterable: [:title, :url],
    sortable: [:id, :updated_at],
    default_order: %{
      order_by: [:id],
      order_directions: [:desc]
    }
  }

  schema "links" do
    field :title, :string
    field :url, :string

    # field :user_id, :id
    belongs_to :user, Slink.Accounts.User
    has_many :user_links, Slink.Links.UserLink, foreign_key: :link_id
    # many_to_many :tags, Tag, join_through: "link_tags", on_replace: :delete
    many_to_many :tags, Tag, join_through: LinkTag, on_replace: :delete

    # list show index in one page
    field :list_index, :integer, virtual: true
    # attach current-scope user_link
    field :my_ulink, :map, virtual: true
    field :input_tags, :string, virtual: true
    # field :input_tags, {:array, :string}, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc """
  New changeset allow inserted_at, updated_at builtin attributes
  """
  def new_changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> Ecto.Changeset.change(attrs)
    |> unique_constraint(:url, name: "links_url_index")
  end

  @doc """
  Get new attributes from a link struct.
  """
  def get_new_attrs(%__MODULE__{} = link) do
    link
    |> Map.from_struct()
    # ignore local :id to avoid id-sequence conflict
    |> Map.take([
      :title,
      :url,
      :user_id,
      :inserted_at,
      :updated_at
    ])
  end

  @doc """
  Link changeset accepted tags in "tags" or :tags, a string separated by comma or list of strings
  """
  def changeset(link, attrs, user_scope) do
    link
    |> cast(attrs, [:title, :url, :input_tags])
    |> validate_required([:title, :url])
    |> validate_length(:title, min: 2, max: 200)
    |> validate_length(:url, min: 5, max: 255)
    |> unique_constraint(:url, name: "links_url_index")
    |> prepare_changes(fn cs ->
      input_tags = cs.changes[:input_tags]
      # todo
      # check name length
      # keep tags order

      if input_tags do
        cs |> tags_changeset(input_tags, user_scope)
      else
        cs
      end
    end)
    |> put_change(:user_id, user_scope.user.id)
  end

  def tags_changeset(cs, input_tags, user_scope) do
    cs
    |> put_assoc(:tags, parse_tags(input_tags, user_scope))
  end

  # https://hexdocs.pm/ecto/3.13.2/constraints-and-upserts.html
  defp parse_tags(input_tags, user_scope) do
    input_tags
    |> do_parse_tags()
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> insert_and_get_all(user_scope)
  end

  defp do_parse_tags(tags) when is_binary(tags), do: tags |> String.split(",")
  defp do_parse_tags(tags) when is_list(tags), do: tags

  defp insert_and_get_all([], _), do: []

  defp insert_and_get_all(names, user_scope) do
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

    # fix: order lost
    Repo.all(from t in Tag, where: t.name in ^names)
  end
end
