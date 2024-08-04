defmodule Slink.Repo.Migrations.CreateAdminUsers do
  use Ecto.Migration

  def change do
    create table(:admin_users) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :role, :string, null: false
      add :by_admin_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:admin_users, [:user_id])
    create index(:admin_users, [:by_admin_id])
  end
end
