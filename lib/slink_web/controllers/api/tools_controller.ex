defmodule SlinkWeb.Api.ToolsController do
  use SlinkWeb, :controller

  def home(%{adapter: {Bandit.Adapter, adapter}} = conn, _params) do
    http_version = Bandit.HTTPTransport.version(adapter.transport)

    json(conn, %{
      msg: "ok",
      http_version: http_version
    })
  end

  def ping(conn, _params) do
    json(conn, %{msg: "pong"})
  end

  @max_ms 3000
  def delay(conn, %{"num" => num_ms}) do
    ms = String.to_integer(num_ms)

    {ms, msg} =
      if ms <= @max_ms do
        {ms, "ok"}
      else
        {@max_ms, "too large"}
      end

    :timer.sleep(ms)

    json(conn, %{
      delay: ms,
      unit: :ms,
      msg: msg
    })
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
