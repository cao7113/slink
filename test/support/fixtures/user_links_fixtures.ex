defmodule Slink.UserLinksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Slink.UserLinks` context.
  """

  @doc """
  Generate a user_link.
  """
  def user_link_fixture(scope, attrs \\ %{}) do
    default_attrs =
      %{
        title: "some title"
      }
      |> Map.put_new_lazy(:link_id, fn ->
        link = Slink.LinksFixtures.link_fixture(scope)
        link.id
      end)

    attrs = Enum.into(attrs, default_attrs)
    {:ok, user_link} = Slink.UserLinks.create_user_link(scope, attrs)
    user_link
  end
end
