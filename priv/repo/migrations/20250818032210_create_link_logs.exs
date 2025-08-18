defmodule Slink.Repo.Migrations.CreateLinkLogs do
  use Ecto.Migration

  def change do
    create table(:link_logs) do
      add :event, :string, null: false
      add :link_id, references(:links, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:link_logs, [:user_id, :link_id])
    create index(:link_logs, [:link_id])
    create index(:link_logs, [:event])
  end
end
