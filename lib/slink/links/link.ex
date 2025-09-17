defmodule Slink.Links.Link do
  use Endon
  use Ecto.Schema

  import Ecto.Changeset

  alias Slink.Tags
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
    many_to_many :tags, Tag, join_through: LinkTag, on_replace: :delete
    belongs_to :site, Slink.Sites.Site

    # list show index in one page
    field :list_index, :integer, virtual: true
    # attach current-scope user_link
    field :my_ulink, :map, virtual: true
    # for tag input
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
    |> cast(attrs, [:title, :url, :input_tags, :site_id])
    |> validate_required([:title, :url])
    |> validate_length(:title, min: 2, max: 200)
    |> validate_length(:url, min: 5, max: 255)
    |> unique_constraint(:url, name: "links_url_index")
    |> validate_format(:url, ~r/^https?:\/\//i, message: "must start with http:// or https://")
    |> prepare_changes(fn cs ->
      input_tags = cs.changes[:input_tags]
      put_tags_changeset(cs, input_tags, user_scope)
    end)
    |> put_change(:user_id, user_scope.user.id)
  end

  def put_tags_changeset(cs, nil, _scope), do: cs

  def put_tags_changeset(cs, input_tags, user_scope) do
    tags = Tags.filter_and_ensure_tags(input_tags, user_scope)

    cs
    |> put_change(:tags, tags)
    |> put_change(:updated_at, DateTime.utc_now(:second))
  end
end
