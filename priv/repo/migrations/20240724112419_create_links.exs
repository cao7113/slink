defmodule Slink.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :title, :string
      add :user_id, :integer, null: false
      add :url, :string, null: false, size: 300

      timestamps(type: :utc_datetime)
    end

    create unique_index(:links, [:url])
  end
end
