defmodule Maper do
  @moduledoc """
  Map Helper
  """

  @doc """
  Atomize map keys
  """
  def atomlize_keys(%{} = map, opts \\ []) do
    permits = Keyword.get(opts, :permits, Map.keys(map))

    new_map =
      map
      |> Map.take(permits)
      |> Enum.map(fn
        {k, v} when is_binary(k) -> {String.to_atom(k), v}
        kv -> kv
      end)
      |> Enum.into(%{})

    new_map
  end

  @doc """
  Stringize map keys
  """
  def stringize_keys(%{} = map, opts \\ []) do
    permits = Keyword.get(opts, :permits, Map.keys(map))

    map
    |> Map.take(permits)
    |> Enum.map(fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      kv -> kv
    end)
    |> Enum.into(%{})
  end
end
