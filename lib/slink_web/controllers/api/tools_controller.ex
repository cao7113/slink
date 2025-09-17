defmodule SlinkWeb.Api.ToolsController do
  use SlinkWeb, :controller

  def home(conn, _params) do
    json(conn, %{msg: "ok"})
  end

  def ping(conn, _params) do
    json(conn, %{msg: "pong"})
  end

  def info(conn, _params) do
    user = (conn.assigns.current_scope || %{}) |> Map.get(:user)

    body =
      if user do
        %{
          msg: "Authorized",
          user: %{
            email: user.email
          }
        }
      else
        %{
          msg: "Unauthorized"
        }
      end

    json(conn, body)
  end
end
