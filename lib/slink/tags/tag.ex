defmodule Slink.Tags.Tag do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :group, :string

    # field :user_id, :id
    belongs_to :user, Slink.Accounts.User
    many_to_many :links, Slink.Links.Link, join_through: Slink.Links.LinkTag
    field :links_count, :integer, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs, user_scope) do
    tag
    |> cast(attrs, [:name, :group])
    |> validate_required([:name])
    |> validate_name_length()
    |> validate_format(:name, ~r/^[\w\-]+$/,
      message: "only contain letters, numbers, underscore and hyphens"
    )
    |> unique_constraint(:name, name: "tags_name_index")
    |> put_change(:user_id, user_scope.user.id)
  end

  def validate_name_length(cs) do
    cs |> validate_length(:name, min: 1, max: 60)
  end
end
