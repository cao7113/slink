# defmodule SlinkWeb.Admin.UserLiveTest do
#   use SlinkWeb.ConnCase

#   import Phoenix.LiveViewTest
#   import Slink.AccountsFixtures

#   @create_attrs %{name: "some name", email: "some email", site: "some site", confirmed_at: "2025-08-18T06:58:00Z", admin_role: "some admin_role", inserted_at: "2025-08-18T06:58:00Z", updated_at: "2025-08-18T06:58:00Z"}
#   @update_attrs %{name: "some updated name", email: "some updated email", site: "some updated site", confirmed_at: "2025-08-19T06:58:00Z", admin_role: "some updated admin_role", inserted_at: "2025-08-19T06:58:00Z", updated_at: "2025-08-19T06:58:00Z"}
#   @invalid_attrs %{name: nil, email: nil, site: nil, confirmed_at: nil, admin_role: nil, inserted_at: nil, updated_at: nil}

#   setup :register_and_log_in_user

#   defp create_user(%{scope: scope}) do
#     user = user_fixture(scope)

#     %{user: user}
#   end

#   describe "Index" do
#     setup [:create_user]

#     test "lists all users", %{conn: conn, user: user} do
#       {:ok, _index_live, html} = live(conn, ~p"/admin/users")

#       assert html =~ "Listing Users"
#       assert html =~ user.email
#     end

#     test "saves new user", %{conn: conn} do
#       {:ok, index_live, _html} = live(conn, ~p"/admin/users")

#       assert {:ok, form_live, _} =
#                index_live
#                |> element("a", "New User")
#                |> render_click()
#                |> follow_redirect(conn, ~p"/admin/users/new")

#       assert render(form_live) =~ "New User"

#       assert form_live
#              |> form("#user-form", user: @invalid_attrs)
#              |> render_change() =~ "can&#39;t be blank"

#       assert {:ok, index_live, _html} =
#                form_live
#                |> form("#user-form", user: @create_attrs)
#                |> render_submit()
#                |> follow_redirect(conn, ~p"/admin/users")

#       html = render(index_live)
#       assert html =~ "User created successfully"
#       assert html =~ "some email"
#     end

#     test "updates user in listing", %{conn: conn, user: user} do
#       {:ok, index_live, _html} = live(conn, ~p"/admin/users")

#       assert {:ok, form_live, _html} =
#                index_live
#                |> element("#users-#{user.id} a", "Edit")
#                |> render_click()
#                |> follow_redirect(conn, ~p"/admin/users/#{user}/edit")

#       assert render(form_live) =~ "Edit User"

#       assert form_live
#              |> form("#user-form", user: @invalid_attrs)
#              |> render_change() =~ "can&#39;t be blank"

#       assert {:ok, index_live, _html} =
#                form_live
#                |> form("#user-form", user: @update_attrs)
#                |> render_submit()
#                |> follow_redirect(conn, ~p"/admin/users")

#       html = render(index_live)
#       assert html =~ "User updated successfully"
#       assert html =~ "some updated email"
#     end

#     test "deletes user in listing", %{conn: conn, user: user} do
#       {:ok, index_live, _html} = live(conn, ~p"/admin/users")

#       assert index_live |> element("#users-#{user.id} a", "Delete") |> render_click()
#       refute has_element?(index_live, "#users-#{user.id}")
#     end
#   end

#   describe "Show" do
#     setup [:create_user]

#     test "displays user", %{conn: conn, user: user} do
#       {:ok, _show_live, html} = live(conn, ~p"/admin/users/#{user}")

#       assert html =~ "Show User"
#       assert html =~ user.email
#     end

#     test "updates user and returns to show", %{conn: conn, user: user} do
#       {:ok, show_live, _html} = live(conn, ~p"/admin/users/#{user}")

#       assert {:ok, form_live, _} =
#                show_live
#                |> element("a", "Edit")
#                |> render_click()
#                |> follow_redirect(conn, ~p"/admin/users/#{user}/edit?return_to=show")

#       assert render(form_live) =~ "Edit User"

#       assert form_live
#              |> form("#user-form", user: @invalid_attrs)
#              |> render_change() =~ "can&#39;t be blank"

#       assert {:ok, show_live, _html} =
#                form_live
#                |> form("#user-form", user: @update_attrs)
#                |> render_submit()
#                |> follow_redirect(conn, ~p"/admin/users/#{user}")

#       html = render(show_live)
#       assert html =~ "User updated successfully"
#       assert html =~ "some updated email"
#     end
#   end
# end
