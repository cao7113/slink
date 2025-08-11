defmodule SlinkWeb.Api.ToolsControllerTest do
  use SlinkWeb.ConnCase, async: true

  import Slink.AccountsFixtures

  setup do
    %{unconfirmed_user: unconfirmed_user_fixture(), user: user_fixture()}
  end

  describe "GET /api/ping" do
    test "ping-pong", %{conn: conn} do
      conn = get(conn, ~p"/api/ping")
      info = json_response(conn, 200)
      assert info["msg"] == "pong"
    end
  end

  describe "GET /api/info" do
    test "user authorized", %{conn: conn, user: user} do
      conn =
        conn
        |> put_user_api_token(user: user)
        |> get(~p"/api/info")

      info = json_response(conn, 200)
      assert info["msg"] == "Authorized"
      assert info["user"]["email"] == user.email
    end

    test "user unauthorized", %{conn: conn} do
      conn =
        conn
        |> get(~p"/api/info")

      info = json_response(conn, 200)
      assert info["msg"] == "Unauthorized"
    end
  end

  describe "GET /api/info/builder" do
    test "user authorized", %{conn: conn, user: user} do
      conn =
        conn
        |> put_user_api_token(user: user)
        |> get(~p"/api/info/builder")

      %{
        "builder" => _,
        "release" => _
      } = json_response(conn, 200)
    end
  end
end
