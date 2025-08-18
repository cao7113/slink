defmodule Slink.Repo.Migrations.CreateUserLinks do
  use Ecto.Migration

  def change do
    create table(:user_links) do
      add :link_id, references(:links, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :id, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :last_visit_at, :utc_datetime, null: false
      add :total_visit_times, :integer, null: false, default: 0
      add :favor_at, :utc_datetime
      add :note, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_links, [:user_id, :link_id])
    create index(:user_links, [:link_id])
  end
end
