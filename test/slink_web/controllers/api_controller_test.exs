defmodule SlinkWeb.ApiControllerTest do
  use SlinkWeb.ConnCase

  test "GET /api/ping", %{conn: conn} do
    conn = get(conn, ~p"/api/ping")
    assert json_response(conn, 200) == %{"msg" => "pong"}
  end
end
