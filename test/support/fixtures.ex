defmodule Slink.Fixtures do
  @moduledoc """
  This module defines common test helpers for creating
  entities.
  """

  @doc """
  Batch gen specified fixtures
  """
  def batch_gen(gen_fun \\ &Slink.LinksFixtures.link_fixture/0, n \\ Enum.random(1..10))
      when is_function(gen_fun, 0) do
    Enum.each(1..n, fn _ -> gen_fun.() end)
  end
end
