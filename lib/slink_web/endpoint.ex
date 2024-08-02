defmodule SlinkWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :slink

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_slink_key",
    signing_salt: "ADBSKw3f",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :slink,
    gzip: false,
    only: SlinkWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :slink
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  # plug(
  #   Corsica,
  #   log: [rejected: :debug],
  #   # origins: "*",
  #   origins: [
  #     "http://localhost:3000",
  #     "http://127.0.0.1:3000",
  #     "http://localhost:8000",
  #     "http://127.0.0.1:8000",
  #     "http://localhost:4000",
  #     "http://localhost:4001",
  #     ~r{^https://(.*\.?)link\fly\.dev$}
  #   ],
  #   allow_headers: [
  #     "authorization",
  #     "content-type",
  #     "accept-language",
  #     "special",
  #     "accept",
  #     "origin",
  #     "x-requested-with"
  #   ],
  #   allow_credentials: true,
  #   max_age: 600
  # )

  plug(
    Corsica,
    # TODO: put in config part
    origins: "*",
    allow_methods: :all,
    allow_headers: :all,
    allow_credentials: true,
    max_age: 600
  )

  plug SlinkWeb.Router
end
