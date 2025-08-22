defmodule SlinkWeb.Api.UserLinkControllerTest do
  use SlinkWeb.ConnCase

  import Slink.AccountsFixtures
  import Slink.LinksFixtures
  import Slink.UserLinksFixtures
  alias Slink.Links.UserLink

  @create_attrs %{
    title: "some title",
    url: "http://some.url",
    note: "some note"
  }
  @update_attrs %{
    title: "some updated title",
    note: "some updated note"
  }
  @invalid_attrs %{title: nil, note: nil}

  setup :register_and_log_in_user

  setup %{conn: conn, user: user} do
    unauthed_conn = put_req_header(conn, "accept", "application/json")
    conn = log_in_user_by_api_token(unauthed_conn, user: user)
    {:ok, unauthed_conn: unauthed_conn, conn: conn}
  end

  describe "index" do
    test "lists all user_links", %{conn: conn} do
      conn = get(conn, ~p"/api/user_links")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_link" do
    test "renders user_link when data is valid", %{conn: conn, user: user} do
      scope = user_scope_fixture(user)
      link = link_fixture(scope)
      attrs = @create_attrs |> Map.put(:link_id, link.id)
      conn = post(conn, ~p"/api/user_links", user_link: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/user_links/#{id}")

      assert %{
               "id" => ^id,
               "note" => "some note",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    @tag capture_log: true
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/user_links", user_link: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_link" do
    setup [:create_user_link]

    test "renders user_link when data is valid", %{
      conn: conn,
      user_link: %UserLink{id: id} = user_link
    } do
      conn = put(conn, ~p"/api/user_links/#{user_link}", user_link: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/user_links/#{id}")

      assert %{
               "id" => ^id,
               "note" => "some updated note",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    @tag capture_log: true
    test "renders errors when data is invalid", %{conn: conn, user_link: user_link} do
      conn = put(conn, ~p"/api/user_links/#{user_link}", user_link: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_link" do
    setup [:create_user_link]

    test "deletes chosen user_link", %{conn: conn, user_link: user_link} do
      conn = delete(conn, ~p"/api/user_links/#{user_link}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/user_links/#{user_link}")
      end
    end
  end

  defp create_user_link(%{scope: scope}) do
    user_link = user_link_fixture(scope)

    %{user_link: user_link}
  end
end
