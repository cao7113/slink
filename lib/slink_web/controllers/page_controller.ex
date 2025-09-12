defmodule SlinkWeb.PageController do
  use SlinkWeb, :controller

  def info(conn, _params) do
    conn
    |> assign(:user_agent, get_req_header(conn, "user-agent"))
    |> render(:info)
  end

  def home(conn, _params) do
    render(conn, :home)
  end

  def ui(conn, _params) do
    conn
    |> render(:ui)
  end

  def test(conn, _params) do
    conn
    |> put_root_layout(html: false)
    |> render(:test)
  end
end
