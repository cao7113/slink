defmodule Slink.Repo.Migrations.AddDescToTags do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :desc, :string
    end

    create index(:tags, [:desc])
  end
end
