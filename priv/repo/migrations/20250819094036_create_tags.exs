defmodule Slink.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string, size: 60, null: false
      add :group, :string, size: 60
      add :user_id, references(:users, type: :id, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tags, ["(lower(name))"], name: :tags_lower_name_index)
    create index(:tags, [:name])
    create index(:tags, [:group])
    create index(:tags, [:user_id])
  end
end
