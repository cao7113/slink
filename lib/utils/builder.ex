defmodule Builder do
  def app, do: Application.get_application(__MODULE__)
  def vsn, do: Application.spec(app(), :vsn) |> to_string()
  def scm_url, do: Application.get_env(app(), :scm_url)

  ## Build Info

  def info do
    %{
      app: app(),
      version: vsn(),
      scm_url: scm_url(),
      build_mode: build_mode(),
      build_time: build_time(),
      system: System.build_info(),
      commit: commit(),
      node: Node.self()
    }
  end

  def build_mode, do: Application.get_env(app(), :build_mode)
  def build_time, do: Application.get_env(app(), :build_time) |> to_string

  def is_dev?, do: build_mode() == :dev
  def is_prod?, do: build_mode() == :prod
  def is_test?, do: build_mode() == :test

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

  ## Pkg info
  def pkg_info do
    [:phoenix, :ecto, :req]
    |> Enum.map(fn app ->
      %{
        app: app,
        vsn: Application.spec(app, :vsn) |> to_string(),
        desc: Application.spec(app, :description) |> to_string()
      }
    end)
  end

  ## Release Info

  def release_info do
    vars = release_env_vars()
    rel_root = vars["RELEASE_ROOT"]

    if rel_root do
      init_file_cookie = File.read!(Path.join([rel_root, "releases/COOKIE"]))
      vars |> Map.put("RELEASE_COOKIE_FILE_VALUE", init_file_cookie)
    else
      vars
    end
  end

  def release_env_vars do
    ~w[
      RELEASE_ROOT
      RELEASE_NAME
      RELEASE_VSN
      RELEASE_PROG
      RELEASE_COMMAND
      RELEASE_DISTRIBUTION
      RELEASE_NODE
      RELEASE_COOKIE
      RELEASE_SYS_CONFIG
      RELEASE_VM_ARGS
      RELEASE_REMOTE_VM_ARGS
      RELEASE_TMP
      RELEASE_MODE
      RELEASE_BOOT_SCRIPT
      RELEASE_BOOT_SCRIPT_CLEAN
    ]
    |> Enum.into(%{}, fn env ->
      {env, System.get_env(env, nil)}
    end)
  end
end
