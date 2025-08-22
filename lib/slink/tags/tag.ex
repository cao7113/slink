defmodule Slink.Tags.Tag do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :group, :string
    # field :user_id, :id
    belongs_to :user, Slink.Accounts.User
    # many_to_many :links, Slink.Links.Link, join_through: "link_tags"
    many_to_many :links, Slink.Links.Link, join_through: Slink.Links.LinkTag

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs, user_scope) do
    tag
    |> cast(attrs, [:name, :group])
    |> validate_required([:name])
    |> check_name_length()
    |> unique_constraint(:name, name: "tags_name_index")
    |> put_change(:user_id, user_scope.user.id)
  end

  def check_name_length(cs) do
    cs
    |> validate_length(:name, min: 2, max: 60)
  end
end
