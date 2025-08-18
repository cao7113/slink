defmodule SlinkWeb.My.UserTokenLiveTest do
  use SlinkWeb.ConnCase

  import Phoenix.LiveViewTest
  # import Slink.AccountsFixtures

  setup :register_and_log_in_user

  describe "Index" do
    test "lists all user_tokens", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/my/user_tokens")

      assert html =~ "Listing My tokens"
      assert html =~ "User Tokens"
    end

    test "create api-token", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/my/user_tokens")

      created_api_html =
        index_live
        |> element("button", "Create API token")
        |> render_click()

      assert created_api_html =~ "Cateated API token ID="
    end
  end
end
