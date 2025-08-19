defmodule Slink.Repo.Migrations.AddAdminRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :admin_role, :string, comment: "Admin role"
      add :avatar_url, :string, comment: "User avatar URL"
    end

    create index(:users, [:admin_role])
  end
end
