defmodule Slink.Sites.Site do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :name, :string
    field :url, :string
    field :logo_url, :string
    field :category, :string
    field :intro, :string

    # field :user_id, :id
    belongs_to :user, Slink.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(site, attrs, user_scope) do
    site
    |> cast(attrs, [:name, :url, :logo_url, :category, :intro])
    |> validate_required([:name, :url])
    |> validate_length(:name, min: 1, max: 60)
    |> validate_length(:url, min: 4, max: 60)
    |> unique_constraint(:name, name: "sites_name_index")
    |> unique_constraint(:url, name: "sites_url_index")
    |> put_change(:user_id, user_scope.user.id)
  end
end
