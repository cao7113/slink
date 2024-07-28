defmodule Slink.LinksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Slink.Links` context.
  """

  @doc """
  Generate a unique link url.
  """
  def unique_link_url, do: "http://localhost:4000/links/#{System.unique_integer([:positive])}"

  @doc """
  Generate a link.
  """
  def link_fixture(attrs \\ []) do
    {:ok, link} =
      attrs
      |> Enum.into(%{
        title: Faker.Lorem.sentence(),
        url: unique_link_url(),
        user_id: 1
      })
      |> Slink.Links.create_link()

    link
  end
end
