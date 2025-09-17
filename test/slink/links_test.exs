defmodule Slink.LinksTest do
  use Slink.DataCase

  alias Slink.Links

  describe "links" do
    alias Slink.Links.Link

    import Slink.AccountsFixtures, only: [user_scope_fixture: 0]
    import Slink.LinksFixtures

    @invalid_attrs %{title: nil, url: nil}

    test "get_link!/2 returns the link with given id" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      other_scope = user_scope_fixture()
      assert Links.get_link!(scope, link.id) == link
      assert_raise Ecto.NoResultsError, fn -> Links.get_link!(other_scope, link.id) end
    end

    test "create_link/2 with valid data creates a link" do
      valid_attrs = %{title: "some title", url: "http://some.url"}
      scope = user_scope_fixture()

      assert {:ok, %Link{} = link} = Links.create_link(scope, valid_attrs)
      assert link.title == "some title"
      assert link.url == "http://some.url"
      assert link.user_id == scope.user.id

      # re-create with same url
      {:error, %Ecto.Changeset{} = changeset} = Links.create_link(scope, valid_attrs)

      assert changeset.errors == [
               url:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "links_url_index"]}
             ]

      refute changeset.valid?
    end

    test "create_link/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Links.create_link(scope, @invalid_attrs)
    end

    test "update_link/3 with valid data updates the link" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      update_attrs = %{title: "some updated title", url: unique_link_url()}

      assert {:ok, %Link{} = link} = Links.update_link(scope, link, update_attrs)
      assert link.title == "some updated title"
      assert link.url == update_attrs.url
    end

    test "update_link/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      link = link_fixture(scope)

      assert_raise MatchError, fn ->
        Links.update_link(other_scope, link, %{})
      end
    end

    test "update_link/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Links.update_link(scope, link, @invalid_attrs)
      assert link == Links.get_link!(scope, link.id)
    end

    test "delete_link/2 deletes the link" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      assert {:ok, %Link{}} = Links.delete_link(scope, link)
      assert_raise Ecto.NoResultsError, fn -> Links.get_link!(scope, link.id) end
    end

    test "delete_link/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      link = link_fixture(scope)
      assert_raise MatchError, fn -> Links.delete_link(other_scope, link) end
    end

    test "change_link/2 returns a link changeset" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      assert %Ecto.Changeset{} = Links.change_link(scope, link)
    end
  end

  describe "links with tags" do
    # @describetag :try

    alias Slink.Links.Link
    import Slink.AccountsFixtures, only: [user_scope_fixture: 0]
    import Slink.LinksFixtures

    test "insert with tags" do
      scope = user_scope_fixture()

      attrs = %{
        url: Slink.LinksFixtures.unique_link_url(),
        title: "Test title",
        input_tags: "tag1, tag2"
      }

      %{tags: tags} =
        link =
        Link.changeset(%Link{}, attrs, scope)
        |> Slink.Repo.insert!()
        |> Slink.Repo.preload(:tags)

      assert length(tags) == 2

      %{tags: [tag]} =
        link
        |> Ecto.Changeset.change()
        |> Link.put_tags_changeset("tag1", scope)
        |> Repo.update!()
        |> Repo.preload(:tags)

      assert tag.name == "tag1"

      %{tags: []} =
        link
        |> Ecto.Changeset.change()
        |> Link.put_tags_changeset("", scope)
        |> Repo.update!()
        |> Repo.preload(:tags)
    end
  end

  describe "create attrs" do
    @describetag :try

    alias Slink.Links.Link
    import Slink.AccountsFixtures, only: [user_scope_fixture: 0]
    import Slink.LinksFixtures

    test "manual inserted_at" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      attrs = link |> Link.get_new_attrs()

      manual_inserted_at =
        DateTime.utc_now() |> DateTime.add(-48, :hour) |> DateTime.truncate(:second)

      attrs2 = %{
        attrs
        | url: "updated #{link.url}",
          inserted_at: manual_inserted_at
      }

      cs = Link.new_changeset(attrs2)
      link2 = Slink.Repo.insert!(cs)
      assert link2.inserted_at == manual_inserted_at
    end
  end

  describe "flop pagination" do
    @describetag :try

    alias Slink.Links.Link
    import Slink.AccountsFixtures, only: [user_scope_fixture: 0]
    import Slink.LinksFixtures

    # https://hexdocs.pm/flop/Flop.html#module-pagination
    test "cursor based" do
      Links.batch_run_with_cursor(handler: &Enum.count/1)
    end
  end
end
