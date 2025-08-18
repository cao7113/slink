defmodule SlinkWeb.My.UserLinkLiveTest do
  use SlinkWeb.ConnCase

  import Phoenix.LiveViewTest
  import Slink.UserLinksFixtures

  # @create_attrs %{
  #   title: "some title",
  #   note: "some note"
  # }
  # @update_attrs %{
  #   title: "some updated title",
  #   note: "some updated note",
  #   favor_at: "2025-08-15T00:47:00Z",
  #   last_visit_at: "2025-08-15T00:47:00Z",
  #   total_visit_times: 43
  # }
  # @invalid_attrs %{
  #   title: nil,
  #   note: nil
  # }

  setup :register_and_log_in_user

  defp create_user_link(%{scope: scope}) do
    user_link = user_link_fixture(scope)

    %{user_link: user_link}
  end

  describe "Index" do
    setup [:create_user_link]

    test "lists all user_links", %{conn: conn, user_link: user_link} do
      {:ok, _index_live, html} = live(conn, ~p"/my/user_links")

      assert html =~ "Listing User links"
      assert html =~ user_link.title
    end

    # test "saves new user_link", %{conn: conn, user: user} do
    #   {:ok, index_live, _html} = live(conn, ~p"/my/user_links")

    #   assert {:ok, form_live, _} =
    #            index_live
    #            |> element("a", "New User link")
    #            |> render_click()
    #            |> follow_redirect(conn, ~p"/my/user_links/new")

    #   assert render(form_live) =~ "New User link"

    #   assert form_live
    #          |> form("#user_link-form", user_link: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   scope = Slink.AccountsFixtures.user_scope_fixture(user)
    #   link = Slink.LinksFixtures.link_fixture(scope)

    #   attrs =
    #     @create_attrs
    #     |> Map.put(:link_id, link.id)

    #   assert {:ok, index_live, _html} =
    #            form_live
    #            |> form("#user_link-form", user_link: attrs)
    #            |> render_submit()
    #            |> follow_redirect(conn, ~p"/my/user_links")

    #   html = render(index_live)
    #   assert html =~ "User link created successfully"
    #   assert html =~ "some title"
    # end

    # test "updates user_link in listing", %{conn: conn, user_link: user_link} do
    #   {:ok, index_live, _html} = live(conn, ~p"/my/user_links")

    #   assert {:ok, form_live, _html} =
    #            index_live
    #            |> element("#user_links-#{user_link.id} a", "Edit")
    #            |> render_click()
    #            |> follow_redirect(conn, ~p"/my/user_links/#{user_link}/edit")

    #   assert render(form_live) =~ "Edit User link"

    #   assert form_live
    #          |> form("#user_link-form", user_link: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   assert {:ok, index_live, _html} =
    #            form_live
    #            |> form("#user_link-form", user_link: @update_attrs)
    #            |> render_submit()
    #            |> follow_redirect(conn, ~p"/my/user_links")

    #   html = render(index_live)
    #   assert html =~ "User link updated successfully"
    #   assert html =~ "some updated title"
    # end

    test "deletes user_link in listing", %{conn: conn, user_link: user_link} do
      {:ok, index_live, _html} = live(conn, ~p"/my/user_links")

      assert index_live |> element("#user_links-#{user_link.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_links-#{user_link.id}")
    end
  end

  describe "Show" do
    setup [:create_user_link]

    test "displays user_link", %{conn: conn, user_link: user_link} do
      {:ok, _show_live, html} = live(conn, ~p"/my/user_links/#{user_link}")

      assert html =~ "Show User link"
      assert html =~ user_link.title
    end

    # test "updates user_link and returns to show", %{conn: conn, user_link: user_link} do
    #   {:ok, show_live, _html} = live(conn, ~p"/my/user_links/#{user_link}")

    #   assert {:ok, form_live, _} =
    #            show_live
    #            |> element("a", "Edit")
    #            |> render_click()
    #            |> follow_redirect(conn, ~p"/my/user_links/#{user_link}/edit?return_to=show")

    #   assert render(form_live) =~ "Edit User link"

    #   assert form_live
    #          |> form("#user_link-form", user_link: @invalid_attrs)
    #          |> render_change() =~ "can&#39;t be blank"

    #   assert {:ok, show_live, _html} =
    #            form_live
    #            |> form("#user_link-form", user_link: @update_attrs)
    #            |> render_submit()
    #            |> follow_redirect(conn, ~p"/my/user_links/#{user_link}")

    #   html = render(show_live)
    #   assert html =~ "User link updated successfully"
    #   assert html =~ "some updated title"
    # end
  end
end
