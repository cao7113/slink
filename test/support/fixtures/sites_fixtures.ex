defmodule Slink.SitesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Slink.Sites` context.
  """

  @doc """
  Generate a unique site name.
  """
  def unique_site_name, do: "some site-name#{System.unique_integer()}"

  @doc """
  Generate a unique site url.
  """
  def unique_site_url, do: "some site-url#{System.unique_integer()}"

  @doc """
  Generate a site.
  """
  def site_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        category: "some category",
        intro: "some intro",
        logo_url: "some logo_url",
        name: unique_site_name(),
        url: unique_site_url()
      })

    {:ok, site} = Slink.Sites.create_site(scope, attrs)
    site
  end
end
