defmodule Slink do
  @moduledoc """
  Slink keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def app, do: Application.get_application(__MODULE__)
  def vsn, do: Application.spec(app(), :vsn) |> to_string()
  def source_url, do: Application.get_env(app(), :source_url)

  ## Build Info

  def build_info do
    %{
      app: app(),
      version: vsn(),
      source_url: source_url(),
      build_mode: build_mode(),
      build_time: build_time(),
      system: System.build_info(),
      commit: commit(),
      node: Node.self()
    }
  end

  def build_mode, do: Application.get_env(app(), :build_mode)
  def build_time, do: Application.get_env(app(), :build_time) |> to_string

  # put into standalone hex pkg?
  def commit do
    %{
      commit_id: Application.get_env(app(), :commit_id, "") |> String.trim(),
      commit_time: Application.get_env(app(), :commit_time, "") |> parse_commit_time
    }
  end

  def parse_commit_time(""), do: nil

  def parse_commit_time(tm_str),
    do: tm_str |> String.trim() |> String.to_integer() |> DateTime.from_unix!() |> to_string()

  ## Helper Info

  def all_env, do: Application.get_all_env(app())
  def priv_dir, do: :code.priv_dir(app()) |> to_string()
end
