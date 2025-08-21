defmodule Slink.Repo.Migrations.ImproveUsersProfile do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :name, :string, size: 100, null: false
      modify :admin_role, :string, size: 100
      modify :site, :string, size: 200
      add :github_url, :string, size: 200
    end

    create unique_index(:users, [:name])
  end
end
