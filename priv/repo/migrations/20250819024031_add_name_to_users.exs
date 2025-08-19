defmodule Slink.Repo.Migrations.AddNameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      # , null: false
      add :name, :string
      add :bio, :text
      add :site, :string
    end

    # create unique_index(:users, [:name])
  end
end
