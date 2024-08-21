defmodule SlinkWeb.PageController do
  use SlinkWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  @doc """
  Keep original phoenix home page to reference
  """
  def phoenix(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :phoenix, layout: false)
  end

  def try(conn, params) do
    conn
    |> put_root_layout(get_try_layout(params["root_layout"], :root))
    |> put_layout(get_try_layout(params["app_layout"], :app))
    |> render(:try)
  end

  def get_try_layout(l, default) when l in [nil, ""], do: [html: default]
  def get_try_layout(l, _) when l in ["false", "no"], do: false
  def get_try_layout(l, _) when is_binary(l), do: [html: String.to_atom(l)]
end
