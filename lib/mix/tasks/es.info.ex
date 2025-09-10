defmodule Mix.Tasks.Es.Info do
  @moduledoc """
  Get Esbuild info
  """

  use Mix.Task

  def run(_) do
    [
      version: Application.get_env(:esbuild, :version, Esbuild.latest_version()),
      bin_path: Esbuild.bin_path(),
      bin_version: Esbuild.bin_version() |> elem(1),
      changes: "https://github.com/evanw/esbuild/blob/main/CHANGELOG.md",
      hex: "https://github.com/phoenixframework/esbuild/blob/main/CHANGELOG.md"
    ]
    |> IO.inspect(
      label: "Esbuild info",
      pretty: true
    )
  end
end
