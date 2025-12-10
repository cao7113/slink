defmodule Mix.Tasks.Assets.Info do
  @moduledoc """
  Get assets info
  """

  use Mix.Task

  @compile {:no_warn_undefined, [Bun, Tailwind, Esbuild]}
  @app :slink

  def run(_) do
    [
      bun: bun_info(),
      tailwind: tailwind_info(),
      esbuild: esbuild_info()
    ]
    |> IO.inspect(
      label: "Assets info",
      pretty: true
    )
  end

  def bun_info do
    if Code.ensure_loaded?(Bun) do
      [
        version: Application.get_env(:bun, :version, Bun.latest_version()),
        bin_path: Bun.bin_path(),
        bin_version: Bun.bin_version() |> elem(1),
        profile: Application.get_env(:bun, @app, :default),
        changes: "https://github.com/crbelaus/bun/releases",
        hex: "https://hexdocs.pm/bun/Bun.html"
      ]
    end
  end

  def tailwind_info do
    if Code.ensure_loaded?(Tailwind) do
      [
        version: Application.get_env(:tailwind, :version, Tailwind.latest_version()),
        bin_path: Tailwind.bin_path(),
        bin_version: Tailwind.bin_version() |> elem(1),
        profile: Application.get_env(:tailwind, @app, :default),
        changes: "https://github.com/tailwindlabs/tailwindcss/blob/main/CHANGELOG.md",
        hex: "https://github.com/phoenixframework/tailwind/blob/main/CHANGELOG.md"
      ]
    end
  end

  def esbuild_info do
    if Code.ensure_loaded?(Esbuild) do
      [
        version: Application.get_env(:esbuild, :version, Esbuild.latest_version()),
        bin_path: Esbuild.bin_path(),
        bin_version: Esbuild.bin_version() |> elem(1),
        changes: "https://github.com/evanw/esbuild/blob/main/CHANGELOG.md",
        hex: "https://github.com/phoenixframework/esbuild/blob/main/CHANGELOG.md"
      ]
    end
  end
end
