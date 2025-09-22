defmodule Slink.Repo.Migrations.AddConstraintsToLinks do
  use Ecto.Migration

  def change do
    alter table(:links) do
      modify :title, :string, null: false
      modify :url, :string, null: false
      modify :user_id, :integer, null: false
      modify :site_id, :integer, null: false
    end
  end
end
