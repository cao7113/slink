defmodule SlinkWeb.PageController do
  use SlinkWeb, :controller

  def hi(conn, params) do
    if params["dbg"] do
      conn |> dbg
    end

    conn
    |> send_resp(200, "ok")
  end

  def home(conn, _params) do
    render(conn, :home)
  end

  def test(conn, _params) do
    {:test, conn} |> dbg
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
