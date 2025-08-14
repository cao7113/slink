defmodule SlinkWeb.PageController do
  use SlinkWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def daisyui(conn, _params) do
    conn
    |> put_flash(:info, "This is a flash message")
    |> render(:daisyui)
  end
end
