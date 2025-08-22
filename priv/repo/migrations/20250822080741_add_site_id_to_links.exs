defmodule Slink.Repo.Migrations.AddSiteIdToLinks do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add :site_id, references(:sites, on_delete: {:nilify, [:site_id]})
    end

    create index(:links, [:site_id])
  end
end
