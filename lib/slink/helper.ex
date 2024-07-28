defmodule Slink.Helper do
  ## URL string

  def short_url(url, opts \\ [])

  def short_url("http://" <> rest, opts), do: short_url(rest, opts)
  def short_url("https://" <> rest, opts), do: short_url(rest, opts)

  def short_url(rest, opts) do
    limit = opts[:limit] || 20

    rest
    |> String.replace(~r/\.com/, "")
    |> String.slice(0..limit)
  end

  def short_title(str, opts \\ []) do
    limit = opts[:limit] || 20

    str
    |> String.slice(0..limit)
  end
end
