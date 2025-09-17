defmodule Slink.Tags.Tag do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :group, :string

    belongs_to :user, Slink.Accounts.User
    many_to_many :links, Slink.Links.Link, join_through: Slink.Links.LinkTag
    field :links_count, :integer, virtual: true

    timestamps(type: :utc_datetime)
  end

  @max_name_length 60

  @doc false
  def changeset(tag, attrs, user_scope) do
    tag
    |> cast(attrs, [:name, :group])
    |> check_tag_name()
    |> unique_constraint(:name, name: "tags_name_index")
    |> put_change(:user_id, user_scope.user.id)
  end

  def check_tag_name(name) when is_binary(name) do
    change(%__MODULE__{}, name: name)
    |> check_tag_name()
  end

  def check_tag_name(cs) do
    cs
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: @max_name_length)
    |> validate_format(:name, ~r/^[\w\-]+$/u,
      message: "only contain letters, numbers, underscore, hyphens and Chinese characters"
    )
  end
end
