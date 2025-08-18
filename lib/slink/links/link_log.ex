defmodule Slink.Links.LinkLog do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  schema "link_logs" do
    field :event, :string
    field :link_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(link_log, attrs, user_scope) do
    user_id = user_scope && user_scope.user.id

    link_log
    |> cast(attrs, [:event, :link_id, :user_id])
    |> validate_required([:event, :link_id])
    |> put_change(:user_id, user_id)
  end
end
