defmodule Mix.Tasks.Tw.Info do
  @moduledoc """
  Get tailwind info

  ##  mix tailwind.install
  The executable is kept at _build/tailwind-TARGET. Where TARGET is your system target architecture.

  ## Know exact using version, ref below for actual used version!
  - config.exs
  - _build/tailwind-macos-arm64 --help
  - priv/static/assets/css/app.css
  """

  use Mix.Task

  @app :slink

  def run(_) do
    [
      version: Application.get_env(:tailwind, :version, Tailwind.latest_version()),
      bin_path: Tailwind.bin_path(),
      bin_version: Tailwind.bin_version() |> elem(1),
      profile: Application.get_env(:tailwind, @app, :default),
      changes: "https://github.com/tailwindlabs/tailwindcss/blob/main/CHANGELOG.md",
      hex: "https://github.com/phoenixframework/tailwind/blob/main/CHANGELOG.md"
    ]
    |> IO.inspect(
      label: "TailwindCSS info",
      pretty: true
    )
  end
end
