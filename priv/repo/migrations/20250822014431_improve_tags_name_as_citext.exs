defmodule Slink.Repo.Migrations.ImproveTagsNameAsCitext do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      modify :name, :citext, null: false
    end

    drop index(:tags, [:name])
    drop unique_index(:tags, ["(lower(name))"], name: :tags_lower_name_index)
    create unique_index(:tags, [:name], name: "tags_name_index")

    alter table(:link_tags) do
      add :user_id, references(:users, on_delete: {:nilify, [:user_id]})
    end

    create index(:link_tags, [:user_id])
  end
end
