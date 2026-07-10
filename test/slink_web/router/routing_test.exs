defmodule Phoenix.Router.RoutingTest do
  # copied from phoenix test

  use ExUnit.Case, async: true
  use RouterHelper

  # import ExUnit.CaptureLog

  defmodule UserController do
    use Phoenix.Controller, formats: []
    def index(conn, _params), do: text(conn, "users index")
    def show(conn, _params), do: text(conn, "users show")
    def top(conn, _params), do: text(conn, "users top")
    def options(conn, _params), do: text(conn, "users options")
    def connect(conn, _params), do: text(conn, "users connect")
    def trace(conn, _params), do: text(conn, "users trace")
    def not_found(conn, _params), do: text(put_status(conn, :not_found), "not found")
    def image(conn, _params), do: text(conn, conn.params["path"] || "show files")
    def move(conn, _params), do: text(conn, "users move")
    def any(conn, _params), do: text(conn, "users any")
    def raise(_conn, _params), do: raise("boom")
    def exit(_conn, _params), do: exit(:boom)

    def halt(conn, _params) do
      conn
      |> send_resp(401, "Unauthorized")
      |> halt()
    end
  end

  defmodule Router do
    use Phoenix.Router

    get "/", UserController, :index, as: :users
    get "/users/top", UserController, :top, as: :top
    get "/users/:id", UserController, :show, as: :users, metadata: %{access: :user}
    match :*, "/users/fallback", UserController, :any
    get "/exit", UserController, :exit
    get "/halt-controller", UserController, :halt

    match :*, "/any", UserController, :any

    # default log: :debug
    scope log: :info do
      pipe_through :noop
      get "/users/:id/raise", UserController, :raise
      pipe_through :halt
      get "/info", UserController, :raise
    end

    get "/*path", UserController, :not_found

    defp noop(conn, _), do: conn

    defp halt(conn, _) do
      conn |> Plug.Conn.send_resp(401, "Unauthorized") |> halt()
    end
  end

  setup do
    # Logger.disable(self())
    Logger.put_process_level(self(), :none)
    :ok
  end

  test "get root path" do
    conn = call(Router, :get, "/")
    assert conn.status == 200
    assert conn.resp_body == "users index"
  end

  # describe "route_info" do
  #   test " returns route string, path params, and more" do
  #     assert Phoenix.Router.route_info(Router, "GET", "foo/bar/baz", nil) == %{
  #              log: :debug,
  #              path_params: %{"path" => ["foo", "bar", "baz"]},
  #              pipe_through: [],
  #              plug: Phoenix.Router.RoutingTest.UserController,
  #              plug_opts: :not_found,
  #              route: "/*path"
  #            }
  #   end
  # end
end
