defmodule SlinkWeb.PlayLive.Starter do
  @moduledoc """
  Start a liveviw
  """

  use SlinkWeb, :live_view
  alias SlinkWeb.Layouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div>Hello</div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # in live connection
    end

    socket =
      socket
      |> assign(:counter, 0)

    {:ok, socket}
  end

  @impl true
  def handle_event("inc", _params, socket) do
    {:handle_event, self(), socket} |> dbg
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, date: DateTime.utc_now())}
  end
end
