defmodule Maper do
  @moduledoc """
  Map Helper
  """

  @doc """
  Atomize map keys
  """
  def atomlize_keys(%{} = map, permits \\ nil) do
    permits = if is_list(permits), do: permits, else: Map.keys(map)

    map
    |> Map.take(permits)
    |> Enum.map(fn
      {k, v} when is_binary(k) -> {String.to_atom(k), v}
      kv -> kv
    end)
    |> Enum.into(%{})
  end

  @doc """
  Stringize map keys
  """
  def stringize_keys(%{} = map, permits \\ nil) do
    permits = if is_list(permits), do: permits, else: Map.keys(map)

    map
    |> Map.take(permits)
    |> Enum.map(fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      kv -> kv
    end)
    |> Enum.into(%{})
  end
end
