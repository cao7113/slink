defmodule SchemaMigration do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "schema_migrations" do
    field :version, :integer, primary_key: true
    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(migration, attrs) do
    migration
    |> cast(attrs, [:version])
    |> validate_required([:version])
  end
end
