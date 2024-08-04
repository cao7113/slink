defmodule Slink.Accounts.AdminUser do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Slink.Accounts.User
  alias Slink.Accounts.AdminUser

  schema "admin_users" do
    field :role, Ecto.Enum, values: [:super, :operator]

    belongs_to :user, User
    belongs_to :by_admin, AdminUser

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(admin_user, attrs) do
    admin_user
    |> cast(attrs, [:user_id, :role, :by_admin_id])
    |> validate_required([:user_id, :role])
    |> unique_constraint([:user_id])
  end
end
