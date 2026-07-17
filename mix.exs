defmodule Slink.MixProject do
  use Mix.Project

  @scm_url "https://github.com/cao7113/slink"
  # automatically bump version on release by git_ops
  @version "0.3.39"

  def project do
    [
      app: :slink,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      name: "Shareup links",
      docs: docs(),
      scm_url: @scm_url
    ]
  end

  def cli do
    [
      # default_task: "phx.server",
      preferred_envs: [
        "demo.test": :test,
        "dev.init": :dev,
        "dev.reset": :dev,
        "test.reset": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Slink.Application, []},
      extra_applications: [:logger, :runtime_tools] ++ extra_apps(Mix.env())
    ]
  end

  # https://hexdocs.pm/elixir/debugging.html#observer
  def extra_apps(:dev), do: [:observer]
  def extra_apps(_), do: []

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  # allow dev use test-fixtures
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  # https://hexdocs.pm/mix/Mix.Tasks.Deps.html#module-dependency-definition-options
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.8"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.2"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      # {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      # {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      # https://hex.pm/packages/bun
      {:bun, "~> 2.0", runtime: Mix.env() == :dev},
      {:heroicons, heroicons_dep_opts(Mix.env())},
      {:swoosh, "~> 1.19"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.8"},
      {:phoenix_pubsub, "2.2.0"},
      {:plug, "~> 1.18"},
      {:mint_web_socket, "~> 1.0", optional: true},
      {:req_client, "~> 0.1"},

      # App enhancement deps
      {:endon, "~> 2.0"},
      {:flop, "~> 0.26.3"},
      # smtp support for gmail
      {:gen_smtp, "~> 1.3"},
      # {:corsica, "~> 2.1"},

      # Dev Tools
      # LiveDebugger run at http://localhost:4007
      # require chrome extenstion!
      # https://github.com/software-mansion/live-debugger?tab=readme-ov-file#getting-started
      # {:live_debugger, "~> 0.4.0", only: :dev},
      # {:faker, "~> 0.18", only: [:dev, :test]},
      {:tidewave, "~> 0.5", only: [:dev]},
      # Livebook tools
      {:kino, "~> 0.16.0", only: [:dev]},
      {:kino_vega_lite, "~> 0.1.11", only: [:dev]},

      # deployment tool
      {:igniter, "~> 0.6", only: [:dev, :test]},
      {:git_ops, "~> 2.0", only: [:dev], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: [
        "deps.get",
        "ecto.setup",
        # NOTE: compile before assets.setup for ColocatedHook or ColocatedJS
        "compile",
        "assets.setup",
        "assets.build"
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      # assets
      "assets.setup": [
        # "tailwind.install --if-missing",
        # "esbuild.install --if-missing",
        "bun.install --if-missing",
        "bun assets install --verbose"
      ],
      "assets.build": [
        # "tailwind slink",
        # "esbuild slink",
        "bun js",
        "bun css"
      ],
      "assets.deploy": [
        # "tailwind slink --minify",
        # "esbuild slink --minify",
        "bun css --minify",
        "bun js --minify",
        "phx.digest"
      ],
      "assets.clean": ["phx.digest.clean --all"],
      precommit: [
        "compile --warning-as-errors",
        "deps.unlock --unused",
        "format",
        "test"
      ],
      # Helpers
      "ecto.reset.force": ["ecto.drop --force-drop", "ecto.setup"],
      "dev.db.init": ["ecto.drop --force-drop", "ecto.create"],
      "dev.init": ["run run/dev/seed.exs"],
      "dev.reset": ["ecto.reset.force", "dev.init"],
      "test.reset": ["ecto.reset.force"],
      "demo.test": &demo_task/1,
      demo: ["demo.test", "cmd mix demo.test"],
      routes: ["phx.routes"]
    ]
  end

  @heroicons_git_opts [
    github: "tailwindlabs/heroicons",
    tag: "v2.2.0",
    sparse: "optimized",
    app: false,
    compile: false,
    depth: 1
  ]

  def heroicons_dep_opts(:dev) do
    path = "deps/heroicons"

    if File.exists?(path) do
      [path: path, app: false, compile: false]
    else
      @heroicons_git_opts
    end
  end

  def heroicons_dep_opts(_) do
    @heroicons_git_opts
  end

  def demo_task(_args) do
    IO.puts("#" |> String.duplicate(40))
    IO.puts("##  Mix.env(): #{Mix.env()}")
    IO.puts("")
  end

  defp docs do
    [
      main: "readme",
      scm_url: @scm_url,
      source_ref: "v#{@version}",
      extras: [
        "README.md"
      ]
    ]
  end
end
