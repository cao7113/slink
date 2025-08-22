defmodule Slink.Links.Tagger do
  @moduledoc """
  Add link-tags as prebuilt rules
  """

  alias Slink.Accounts.Scope
  alias Slink.Links
  alias Slink.Links.Link

  @title_rules %{
    "elixir" => ~r/elixir|phoenix|hexdocs/i,
    "webui" => ~r/css/i
  }
  @url_rules %{
    "github" => ~r/github\.com/i,
    "elixir" => ~r/hexdocs\.pm/i
  }

  def auto_add_tag(%Scope{} = scope, %Link{title: title, url: url} = link) do
    tags = []

    tags =
      Enum.reduce(@title_rules, tags, fn {tag, reg}, acc ->
        if Regex.match?(reg, title) do
          acc ++ [tag]
        else
          acc
        end
      end)

    tags =
      Enum.reduce(@url_rules, tags, fn {tag, reg}, acc ->
        if Regex.match?(reg, url) do
          acc ++ [tag]
        else
          acc
        end
      end)

    tags
    |> Enum.uniq()
    |> Enum.each(&Links.add_tag(link, &1, scope))

    Links.tags_string_of(link)
  end
end
