defmodule SlinkWeb.LinkLiveTest do
  use SlinkWeb.ConnCase

  import Phoenix.LiveViewTest
  import Slink.LinksFixtures

  # TODO: refactor to separate unlogined and loggined view

  @create_attrs %{title: "some title", url: "http://test.com"}
  @update_attrs %{title: "some updated title", url: "http://test.com/update"}
  @invalid_attrs %{title: nil, url: nil}

  describe "Index" do
    test "lists all links", %{conn: conn} do
      link = link_fixture()
      {:ok, _index_live, html} = live(conn, ~p"/links")

      assert html =~ "Listing Links"
      assert html =~ link.title |> Slink.Helper.short_title()
    end

    test "saves new link", %{conn: conn} do
      %{conn: conn, user: _user} = register_and_log_in_user(%{conn: conn})
      {:ok, index_live, _html} = live(conn, ~p"/links")

      assert index_live |> element("a", "New Link") |> render_click() =~
               "New Link"

      assert_patch(index_live, ~p"/links/new")

      assert index_live
             |> form("#link-form", link: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#link-form", link: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/links")

      html = render(index_live)
      assert html =~ "Link created successfully"
      assert html =~ "some title"
    end

    test "updates link in listing", %{conn: conn} do
      %{conn: conn, user: user} = register_and_log_in_user(%{conn: conn})
      link = link_fixture(user_id: user.id)
      {:ok, index_live, _html} = live(conn, ~p"/links")

      assert index_live |> element("#links-#{link.id} a", "Edit") |> render_click() =~
               "Edit Link"

      assert_patch(index_live, ~p"/links/#{link}/edit")

      assert index_live
             |> form("#link-form", link: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#link-form", link: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/links")

      html = render(index_live)
      assert html =~ "Link updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes link in listing", %{conn: conn} do
      %{conn: conn, user: user} = register_and_log_in_user(%{conn: conn})
      link = link_fixture(user_id: user.id)
      {:ok, index_live, _html} = live(conn, ~p"/links")

      assert index_live |> element("#links-#{link.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#links-#{link.id}")
    end
  end

  describe "Show" do
    test "displays link", %{conn: conn} do
      link = link_fixture()
      {:ok, _show_live, html} = live(conn, ~p"/links/#{link}")

      assert html =~ "Show Link"
      assert html =~ link.title
    end

    test "updates link within modal", %{conn: conn} do
      %{conn: conn, user: user} = register_and_log_in_user(%{conn: conn})
      link = link_fixture(user_id: user.id)

      {:ok, show_live, _html} = live(conn, ~p"/links/#{link}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Link"

      assert_patch(show_live, ~p"/links/#{link}/show/edit")

      assert show_live
             |> form("#link-form", link: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#link-form", link: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/links/#{link}")

      html = render(show_live)
      assert html =~ "Link updated successfully"
      assert html =~ "some updated title"
    end
  end
end
