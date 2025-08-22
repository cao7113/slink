defmodule SlinkWeb.Admin.SiteLiveTest do
  use SlinkWeb.ConnCase

  import Phoenix.LiveViewTest
  import Slink.SitesFixtures

  @create_attrs %{
    name: "some name",
    category: "some category",
    url: "http://some.url",
    logo_url: "some logo_url",
    intro: "some intro"
  }
  @update_attrs %{
    name: "some updated name",
    category: "some updated category",
    url: "some updated url",
    logo_url: "some updated logo_url",
    intro: "some updated intro"
  }
  @invalid_attrs %{name: nil, category: nil, url: nil, logo_url: nil, intro: nil}

  setup :register_and_log_in_user

  defp grant_admin_role(%{user: user}) do
    admin_user = Slink.Accounts.grant_admin_role!(user, Slink.Accounts.admin_confirm_words(user))
    %{user: admin_user}
  end

  setup :grant_admin_role

  defp create_site(%{scope: scope}) do
    site = site_fixture(scope)

    %{site: site}
  end

  describe "Index" do
    setup [:create_site]

    test "lists all sites", %{conn: conn, site: site} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/sites")

      assert html =~ "Listing Sites"
      assert html =~ site.name
    end

    test "saves new site", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/sites")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Site")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/sites/new")

      assert render(form_live) =~ "New Site"

      assert form_live
             |> form("#site-form", site: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#site-form", site: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/sites")

      html = render(index_live)
      assert html =~ "Site created successfully"
      assert html =~ "some name"
    end

    test "updates site in listing", %{conn: conn, site: site} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/sites")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#sites-#{site.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/sites/#{site}/edit")

      assert render(form_live) =~ "Edit Site"

      assert form_live
             |> form("#site-form", site: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#site-form", site: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/sites")

      html = render(index_live)
      assert html =~ "Site updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes site in listing", %{conn: conn, site: site} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/sites")

      assert index_live |> element("#sites-#{site.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sites-#{site.id}")
    end
  end

  describe "Show" do
    setup [:create_site]

    test "displays site", %{conn: conn, site: site} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/sites/#{site}")

      assert html =~ "Show Site"
      assert html =~ site.name
    end

    test "updates site and returns to show", %{conn: conn, site: site} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/sites/#{site}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/sites/#{site}/edit?return_to=show")

      assert render(form_live) =~ "Edit Site"

      assert form_live
             |> form("#site-form", site: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#site-form", site: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/sites/#{site}")

      html = render(show_live)
      assert html =~ "Site updated successfully"
      assert html =~ "some updated name"
    end
  end
end
