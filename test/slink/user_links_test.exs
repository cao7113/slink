defmodule Slink.UserLinksTest do
  use Slink.DataCase

  alias Slink.UserLinks
  alias Slink.LinksFixtures

  describe "user_links" do
    alias Slink.Links.UserLink

    import Slink.AccountsFixtures, only: [user_scope_fixture: 0]
    import Slink.UserLinksFixtures

    @invalid_attrs %{
      title: nil,
      note: nil,
      favor_at: nil,
      last_visit_at: nil,
      total_visit_times: nil
    }

    test "list_user_links/1 returns all scoped user_links" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      user_link = user_link_fixture(scope)
      other_user_link = user_link_fixture(other_scope)
      assert UserLinks.list_user_links(scope) == [user_link]
      assert UserLinks.list_user_links(other_scope) == [other_user_link]
    end

    test "get_user_link!/2 returns the user_link with given id" do
      scope = user_scope_fixture()
      user_link = user_link_fixture(scope)
      other_scope = user_scope_fixture()
      assert UserLinks.get_user_link!(scope, user_link.id) == user_link

      assert_raise Ecto.NoResultsError, fn ->
        UserLinks.get_user_link!(other_scope, user_link.id)
      end
    end

    test "create_user_link/2 with valid data creates a user_link" do
      scope = user_scope_fixture()
      link = LinksFixtures.link_fixture(scope)

      valid_attrs = %{
        title: "some title",
        note: "some note",
        favor_at: ~U[2025-08-14 00:47:00Z],
        link_id: link.id
      }

      assert {:ok, %UserLink{} = user_link} = UserLinks.create_user_link(scope, valid_attrs)
      assert user_link.title == "some title"
      assert user_link.note == "some note"
      assert user_link.favor_at == ~U[2025-08-14 00:47:00Z]
      assert user_link.total_visit_times >= 1
      assert user_link.user_id == scope.user.id
    end

    test "create_user_link/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = UserLinks.create_user_link(scope, @invalid_attrs)
    end

    test "update_user_link/3 with valid data updates the user_link" do
      scope = user_scope_fixture()
      user_link = user_link_fixture(scope)

      update_attrs = %{
        title: "some updated title",
        note: "some updated note",
        favor_at: ~U[2025-08-15 00:47:00Z]
      }

      assert {:ok, %UserLink{} = user_link} =
               UserLinks.update_user_link(scope, user_link, update_attrs)

      assert user_link.title == "some updated title"
      assert user_link.note == "some updated note"
      assert user_link.favor_at == ~U[2025-08-15 00:47:00Z]
    end

    test "update_user_link/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      user_link = user_link_fixture(scope)

      assert_raise MatchError, fn ->
        UserLinks.update_user_link(other_scope, user_link, %{})
      end
    end

    test "update_user_link/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      user_link = user_link_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               UserLinks.update_user_link(scope, user_link, @invalid_attrs)

      assert user_link == UserLinks.get_user_link!(scope, user_link.id)
    end

    test "delete_user_link/2 deletes the user_link" do
      scope = user_scope_fixture()
      user_link = user_link_fixture(scope)
      assert {:ok, %UserLink{}} = UserLinks.delete_user_link(scope, user_link)
      assert_raise Ecto.NoResultsError, fn -> UserLinks.get_user_link!(scope, user_link.id) end
    end

    test "delete_user_link/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      user_link = user_link_fixture(scope)
      assert_raise MatchError, fn -> UserLinks.delete_user_link(other_scope, user_link) end
    end

    test "change_user_link/2 returns a user_link changeset" do
      scope = user_scope_fixture()
      user_link = user_link_fixture(scope)
      assert %Ecto.Changeset{} = UserLinks.change_user_link(scope, user_link)
    end
  end
end
