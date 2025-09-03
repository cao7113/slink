defmodule SlinkWeb.PageController do
  use SlinkWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def tailwind(conn, _params) do
    conn
    |> render(:tailwind)
  end

  def daisyui(conn, _params) do
    conn
    |> render(:daisyui)
  end
end
