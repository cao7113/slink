defmodule Slink.Repo.Migrations.AddPinAtToUserLinks do
  use Ecto.Migration

  def change do
    alter table(:user_links) do
      add :pin_at, :utc_datetime
    end

    create index(:user_links, [:user_id, :pin_at])
  end
end
