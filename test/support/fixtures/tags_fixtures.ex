defmodule Slink.TagsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Slink.Tags` context.
  """

  @doc """
  Generate a unique link url.
  """
  def unique_tag_name, do: "some tag#{System.unique_integer([:positive])}"

  @doc """
  Generate a tag.
  """
  def tag_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        group: "some group",
        name: unique_tag_name()
      })

    {:ok, tag} = Slink.Tags.create_tag(scope, attrs)
    tag
  end
end
