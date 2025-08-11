defmodule RepoHelper do
  def batch_import(items, repo, schema_mod, opts \\ [])
      when is_atom(repo) and is_atom(schema_mod) and is_list(items) do
    items =
      items
      |> Enum.map(fn it ->
        it
        |> Map.merge(%{
          inserted_at: {:placeholder, :inserted_at},
          updated_at: {:placeholder, :updated_at}
        })
      end)

    placeholders = %{
      inserted_at: DateTime.utc_now(:second),
      updated_at: DateTime.utc_now(:second)
    }

    new_opts =
      [
        placeholders: placeholders
      ]
      |> Keyword.merge(opts)

    repo.insert_all(
      schema_mod,
      items,
      new_opts
    )
  end
end
