defmodule Mix.Tasks.Tailwind.Info do
  @moduledoc """
  Get tailwind info

    ##  mix tailwind.install
    tailwind cli at: _build/tailwind*
  """

  use Mix.Task

  def run(_) do
    info =
      %{version: Tailwind.latest_version()}

    info
    |> IO.inspect(
      label: "tailwind info",
      pretty: true
    )
  end
end
