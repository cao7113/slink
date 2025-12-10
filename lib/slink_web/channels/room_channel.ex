defmodule SlinkWeb.RoomChannel do
  @moduledoc """
  Demo phoenix channel

  Channels handle events from clients, so they are similar to Controllers, but there are two key differences. Channel events can go both directions - incoming and outgoing. Channel connections also persist beyond a single request/response cycle. Channels are the highest level abstraction for real-time communication components in Phoenix.

  ## Links
  - https://hexdocs.pm/phoenix/1.8.1/channels.html#the-moving-parts
  - https://hexdocs.pm/phoenix/Phoenix.Channel.html#module-terminate
  """

  use SlinkWeb, :channel
  alias SlinkWeb.Presence
  require Logger

  ## debug
  def socket_info do
    __socket__(:private)
  end

  ## Callbacks

  @impl true
  def join("room:lobby", %{} = payload, socket) do
    Logger.debug("join lobby-room with payload: #{payload |> inspect} in #{self() |> inspect}")

    if socket.assigns[:current_user] do
      send(self(), :after_join)
    end

    {:ok, socket}
  end

  def join("room:" <> room_id, payload, socket) do
    if authorized?(payload) do
      Logger.debug("joining room #{room_id} with payload: #{payload |> inspect}")
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{
      user: socket.assigns.current_user.name,
      body: body
      # self: self() |> inspect(),
      # transport_pid: socket.transport_pid |> inspect(),
      # socket: socket |> Map.take([:id, :topic, :ref, :joined, :join_ref])
    })

    {:noreply, socket}
  end

  def handle_in("client-push", %{}, socket) do
    broadcast!(socket, "new_msg", %{
      body: "reply to client push",
      from_pid: self() |> inspect(),
      ref: socket.ref
    })

    {:noreply, socket}
  end

  @impl true
  def handle_out(_event, _payload, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    name = socket.assigns.current_user.name

    {:ok, _} =
      Presence.track(socket, name, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
