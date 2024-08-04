defmodule Slink.Links.Link do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset

  schema "links" do
    field :title, :string
    # todo: define custom url type?
    field :url, :string
    field :user_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:title, :user_id, :url])
    |> validate_required([:user_id, :url])
    |> unique_constraint(:url)
  end

  def update_changeset(link, attrs, _) do
    changeset(link, attrs)
  end

  def create_changeset(link, attrs, _) do
    changeset(link, attrs)
  end
end
