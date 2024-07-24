defmodule SlinkWeb.ApiController do
  use SlinkWeb, :controller

  action_fallback(SlinkWeb.FallbackController)

  def ping(conn, _params) do
    json(conn, %{
      msg: :pong
    })
  end

  def mock_404(_conn, _) do
    {:error, :not_found}
  end
end
