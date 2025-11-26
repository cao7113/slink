defmodule SlinkWeb.PageController do
  use SlinkWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def test(conn, _params) do
    render(conn, :test)
  end

  def chat(conn, _params) do
    render(conn, :chat)
  end

  def info(conn, _params) do
    conn
    |> assign(:user_agent, get_req_header(conn, "user-agent"))
    |> render(:info)
  end
end
