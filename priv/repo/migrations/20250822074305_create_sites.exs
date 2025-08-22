defmodule Slink.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :name, :string, size: 100, null: false
      add :url, :string, size: 200, null: false
      add :category, :string, size: 50
      add :logo_url, :string, size: 200
      add :intro, :text
      add :user_id, references(:users, type: :id, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sites, [:name])
    create unique_index(:sites, [:url])
  end
end
