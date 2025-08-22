defmodule Slink.SitesTest do
  use Slink.DataCase

  alias Slink.Sites

  describe "sites" do
    alias Slink.Sites.Site

    import Slink.AccountsFixtures, only: [user_scope_fixture: 0]
    import Slink.SitesFixtures

    @invalid_attrs %{name: nil, category: nil, url: nil, logo_url: nil, intro: nil}

    # test "list_sites/1 returns all scoped sites" do
    #   scope = user_scope_fixture()
    #   other_scope = user_scope_fixture()
    #   site = site_fixture(scope)
    #   other_site = site_fixture(other_scope)
    #   assert Sites.list_sites(scope) == [site]
    #   assert Sites.list_sites(other_scope) == [other_site]
    # end

    test "get_site!/2 returns the site with given id" do
      scope = user_scope_fixture()
      site = site_fixture(scope)
      other_scope = user_scope_fixture()
      assert Sites.get_site!(scope, site.id) == site
      assert_raise Ecto.NoResultsError, fn -> Sites.get_site!(other_scope, site.id) end
    end

    test "create_site/2 with valid data creates a site" do
      valid_attrs = %{
        name: "some name",
        category: "some category",
        url: "http://some.url",
        logo_url: "some logo_url",
        intro: "some intro"
      }

      scope = user_scope_fixture()

      assert {:ok, %Site{} = site} = Sites.create_site(scope, valid_attrs)
      assert site.name == "some name"
      assert site.category == "some category"
      assert site.url == "http://some.url"
      assert site.logo_url == "some logo_url"
      assert site.intro == "some intro"
      assert site.user_id == scope.user.id
    end

    test "create_site/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.create_site(scope, @invalid_attrs)
    end

    test "update_site/3 with valid data updates the site" do
      scope = user_scope_fixture()
      site = site_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        category: "some updated category",
        url: "some updated url",
        logo_url: "some updated logo_url",
        intro: "some updated intro"
      }

      assert {:ok, %Site{} = site} = Sites.update_site(scope, site, update_attrs)
      assert site.name == "some updated name"
      assert site.category == "some updated category"
      assert site.url == "some updated url"
      assert site.logo_url == "some updated logo_url"
      assert site.intro == "some updated intro"
    end

    test "update_site/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      site = site_fixture(scope)

      assert_raise MatchError, fn ->
        Sites.update_site(other_scope, site, %{})
      end
    end

    test "update_site/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      site = site_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Sites.update_site(scope, site, @invalid_attrs)
      assert site == Sites.get_site!(scope, site.id)
    end

    test "delete_site/2 deletes the site" do
      scope = user_scope_fixture()
      site = site_fixture(scope)
      assert {:ok, %Site{}} = Sites.delete_site(scope, site)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_site!(scope, site.id) end
    end

    test "delete_site/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      site = site_fixture(scope)
      assert_raise MatchError, fn -> Sites.delete_site(other_scope, site) end
    end

    test "change_site/2 returns a site changeset" do
      scope = user_scope_fixture()
      site = site_fixture(scope)
      assert %Ecto.Changeset{} = Sites.change_site(scope, site)
    end
  end
end
