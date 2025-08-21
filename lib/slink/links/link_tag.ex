defmodule Slink.Links.LinkTag do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  schema "link_tags" do
    field :link_id, :id
    field :tag_id, :id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(link_tag, attrs) do
    link_tag
    |> cast(attrs, [:link_id, :tag_id])
    |> validate_required([:link_id, :tag_id])
    |> unique_constraint([:link_id, :tag_id], name: "link_tags_link_id_tag_id_index")
  end
end
