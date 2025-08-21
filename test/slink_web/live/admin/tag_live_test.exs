defmodule SlinkWeb.Admin.TagLiveTest do
  use SlinkWeb.ConnCase

  import Phoenix.LiveViewTest
  import Slink.TagsFixtures

  @create_attrs %{name: "some name", group: "some group"}
  @update_attrs %{name: "some updated name", group: "some updated group"}
  @invalid_attrs %{name: nil, group: nil}

  setup :register_and_log_in_user

  defp grant_admin_role(%{user: user}) do
    admin_user = Slink.Accounts.grant_admin_role!(user, Slink.Accounts.admin_confirm_words(user))
    %{user: admin_user}
  end

  setup :grant_admin_role

  defp create_tag(%{scope: scope}) do
    tag = tag_fixture(scope)

    %{tag: tag}
  end

  describe "Index" do
    @describetag capture_log: true

    setup [:create_tag]

    test "lists all tags", %{conn: conn, tag: tag} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/tags")

      assert html =~ "Listing Tags"
      assert html =~ tag.name
    end

    test "saves new tag", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/tags")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Tag")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/tags/new")

      assert render(form_live) =~ "New Tag"

      assert form_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#tag-form", tag: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/tags")

      html = render(index_live)
      assert html =~ "Tag created successfully"
      assert html =~ "some name"
    end

    test "updates tag in listing", %{conn: conn, tag: tag} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/tags")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#tags-#{tag.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/tags/#{tag}/edit")

      assert render(form_live) =~ "Edit Tag"

      assert form_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#tag-form", tag: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/tags")

      html = render(index_live)
      assert html =~ "Tag updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes tag in listing", %{conn: conn, tag: tag} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/tags")

      assert index_live |> element("#tags-#{tag.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tags-#{tag.id}")
    end
  end

  describe "Show" do
    @describetag capture_log: true

    setup [:create_tag]

    test "displays tag", %{conn: conn, tag: tag} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/tags/#{tag}")

      assert html =~ "Show Tag"
      assert html =~ tag.name
    end

    test "updates tag and returns to show", %{conn: conn, tag: tag} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/tags/#{tag}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/tags/#{tag}/edit?return_to=show")

      assert render(form_live) =~ "Edit Tag"

      assert form_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#tag-form", tag: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/tags/#{tag}")

      html = render(show_live)
      assert html =~ "Tag updated successfully"
      assert html =~ "some updated name"
    end
  end
end
