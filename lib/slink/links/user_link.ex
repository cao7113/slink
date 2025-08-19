defmodule Slink.Links.UserLink do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_links" do
    field :title, :string
    field :note, :string
    field :favor_at, :utc_datetime
    field :pin_at, :utc_datetime
    field :last_visit_at, :utc_datetime
    field :total_visit_times, :integer
    # field :link_id, :id
    # field :user_id, :id
    belongs_to :link, Slink.Links.Link
    belongs_to :user, Slink.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%{} = user_link, attrs, user_scope) do
    old_total_visit_times = user_link.total_visit_times || 0

    user_link
    |> cast(attrs, [:link_id, :title, :note, :favor_at, :pin_at])
    |> validate_required([:title, :link_id])
    |> validate_length(:title, min: 3, max: 200)
    |> put_change(:user_id, user_scope.user.id)
    |> put_change(:last_visit_at, DateTime.utc_now(:second))
    |> put_change(:total_visit_times, old_total_visit_times + 1)
  end
end
