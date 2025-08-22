defmodule Slink.LinksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Slink.Links` context.
  """

  @doc """
  Generate a unique link url.
  """
  def unique_link_url, do: "http://some.url.test/#{System.unique_integer()}"

  @doc """
  Generate a link.
  """
  def link_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "some title",
        url: unique_link_url()
      })

    {:ok, link} = Slink.Links.create_link(scope, attrs)
    link
  end

  def rand_links(scope, opts \\ []) do
    count = Keyword.get(opts, :count, 5)

    1..count
    |> Enum.map(fn _ ->
      link_fixture(scope)
    end)
  end
end
