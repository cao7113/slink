defmodule Mix.Tasks.Assets.Info do
  @moduledoc """
  Get assets info
  """

  use Mix.Task

  @app :slink

  def run(_) do
    %{
      # esbuild: [
      #   version: Application.get_env(:esbuild, :version, Esbuild.latest_version()),
      #   bin_path: Esbuild.bin_path(),
      #   bin_version: Esbuild.bin_version() |> elem(1),
      #   changes: "https://github.com/evanw/esbuild/blob/main/CHANGELOG.md",
      #   hex: "https://github.com/phoenixframework/esbuild/blob/main/CHANGELOG.md"
      # ],
      tailwind: [
        version: Application.get_env(:tailwind, :version, Tailwind.latest_version()),
        bin_path: Tailwind.bin_path(),
        bin_version: Tailwind.bin_version() |> elem(1),
        profile: Application.get_env(:tailwind, @app, :default),
        changes: "https://github.com/tailwindlabs/tailwindcss/blob/main/CHANGELOG.md",
        hex: "https://github.com/phoenixframework/tailwind/blob/main/CHANGELOG.md"
      ],
      bun: [
        version: Application.get_env(:bun, :version, Bun.latest_version()),
        bin_path: Bun.bin_path(),
        bin_version: Bun.bin_version() |> elem(1),
        profile: Application.get_env(:bun, @app, :default),
        changes: "https://github.com/crbelaus/bun/releases",
        hex: "https://hexdocs.pm/bun/Bun.html"
      ]
    }
    |> IO.inspect(
      label: "Assets info",
      pretty: true
    )
  end
end
