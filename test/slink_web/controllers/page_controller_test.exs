defmodule SlinkWeb.PageControllerTest do
  use SlinkWeb.ConnCase

  test "GET /phoenix", %{conn: conn} do
    conn = get(conn, ~p"/phoenix")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end
end
