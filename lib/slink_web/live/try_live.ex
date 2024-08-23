defmodule SlinkWeb.TryLive do
  @moduledoc """
  Try as https://hexdocs.pm/phoenix_live_view/1.0.0-rc.6/welcome.html#example
  """

  use SlinkWeb, :live_view
  require Logger

  # @doc """
  # assigns data from mount/3 callback
  # """
  # def render(assigns) do
  #   Logger.debug("TryLive render is called #{System.unique_integer([:positive])}")

  #   ~H"""
  #   <div>Override by try_live.html.heex</div>
  #   """
  # end

  @doc """
  The mount callback is invoked when the LiveView starts.
  In it, you can access the request parameters, read information stored in the session (typically information which identifies who is the current user), and a socket. The socket is where we keep all state, including assigns.
  After mount, LiveView will render the page with the values from assigns and send it to the client.
  """
  def mount(_params, _session, socket) do
    Logger.debug("TryLive mount is called #{System.unique_integer([:positive])}")
    temperature = 27

    {
      :ok,
      socket
      |> assign(:temperature, temperature)
    }
  end

  def handle_params(unsigned_params, uri, socket) do
    Logger.debug({"TryLive.handle_params", uri, unsigned_params} |> inspect)
    {:noreply, socket}
  end

  @doc """
  There is a button with a phx-click attribute. When the button is clicked, a "inc_temperature" event is sent to the server, which is matched and handled by the handle_event callback. This callback updates the socket and returns {:noreply, socket} with the updated socket.
  The {:noreply, socket} return means there is no additional replies sent to the browser, only that a new version of the page is rendered. LiveView then computes diffs and sends them to the client.
  """
  def handle_event("inc_temperature", _params, socket) do
    {
      :noreply,
      socket
      |> update(:temperature, &(&1 + 1))
    }
  end

  def handle_event("dec_temperature", _params, socket) do
    {
      :noreply,
      socket
      |> update(:temperature, &(&1 - 1))
    }
  end

  def handle_event("update_temp", %{"key" => "ArrowUp"}, socket) do
    {
      :noreply,
      socket
      |> update(:temperature, &(&1 + 1))
    }
  end

  def handle_event("update_temp", %{"key" => "ArrowDown"}, socket) do
    {
      :noreply,
      socket
      |> update(:temperature, &(&1 - 1))
    }
  end

  def handle_event("update_temp", _, socket) do
    {:noreply, socket}
  end

  def handle_event("wait", %{"duration-ms" => duration}, socket) do
    ms = String.to_integer(duration)
    :timer.sleep(ms)
    {:noreply, socket}
  end
end
