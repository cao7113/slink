# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :endon,
  repo: Slink.Repo

config :flop, repo: Slink.Repo

## Build Info
config :slink,
  build_mode: config_env(),
  build_time: DateTime.utc_now(:second),
  scm_url: Mix.Project.config()[:scm_url],
  commit_id: System.get_env("GIT_COMMIT_ID", ""),
  commit_time: System.get_env("GIT_COMMIT_TIME", "")

config :slink, :scopes,
  user: [
    default: true,
    module: Slink.Accounts.Scope,
    assign_key: :current_scope,
    access_path: [:user, :id],
    schema_key: :user_id,
    schema_type: :id,
    schema_table: :users,
    test_data_fixture: Slink.AccountsFixtures,
    test_setup_helper: :register_and_log_in_user
  ]

config :slink,
  ecto_repos: [Slink.Repo],
  generators: [
    timestamp_type: :utc_datetime,
    # api_prefix: "/api",
    api_prefix: ""
  ]

# Configures the endpoint
config :slink, SlinkWeb.Endpoint,
  # https://hexdocs.pm/bandit/1.6.7/Bandit.html#t:options/0
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SlinkWeb.ErrorHTML, json: SlinkWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Slink.PubSub,
  live_view: [signing_salt: "nzjY3ntd"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :slink, Slink.Mailer, adapter: Swoosh.Adapters.Local

# https://github.com/crbelaus/bun?tab=readme-ov-file#adding-to-phoenix
config :bun,
  # run mix bun.install --if-missing
  # NOTE: maybe rm _build/bun before install new version
  version: "1.3.4",
  # mix bun assets --version
  assets: [
    args: [],
    cd: Path.expand("../assets", __DIR__)
  ],
  js: [
    args:
      ~w(build js/app.js --outdir=../priv/static/assets/js --external /fonts/* --external /images/*),
    cd: Path.expand("../assets", __DIR__)
    # env: %{
    #   "NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()] |> Enum.join(":")
    # }
  ],
  css: [
    # not work in Dockerfile???
    # --bun x tailwindcss --input=css/app.css --output=../priv/static/assets/css/app.css
    args: ~w(run tailwindcss --input=css/app.css --output=../priv/static/assets/css/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

config :phoenix_live_view, :colocated_js,
  target_directory: Path.expand("../assets/node_modules/phoenix-colocated", __DIR__)

# # Configure esbuild (the version is required)
# config :esbuild,
#   # https://github.com/evanw/esbuild/releases
#   # run after updated version: mix esbuild.install --if-missing
#   version: "0.25.9",
#   slink: [
#     args:
#       ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
#     cd: Path.expand("../assets", __DIR__),
#     env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
#   ]

# # Configure tailwind (the version is required)
# config :tailwind,
#   # https://github.com/tailwindlabs/tailwindcss/releases/
#   # run below after changed the version:
#   # mix tailwind.install --if-missing # or
#   # mix asset.setup
#   version: "4.1.13",
#   slink: [
#     args: ~w(
#       --input=assets/css/app.css
#       --output=priv/static/assets/css/app.css
#     ),
#     cd: Path.expand("..", __DIR__)
#   ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
