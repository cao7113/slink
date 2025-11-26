defmodule SlinkWeb.PlayLive.Online do
  use SlinkWeb, :live_view

  alias SlinkWeb.Presence.Live, as: Presence

  def mount(params, _session, socket) do
    socket = stream(socket, :presences, [])

    socket =
      if connected?(socket) do
        Presence.track_user(params["name"], %{id: params["name"]})
        Presence.subscribe()
        stream(socket, :presences, Presence.list_online_users())
      else
        socket
      end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>Online users with devices(see lib/slink_web/channels/presence.ex)</div>
    <div>Open another tab with other user name to see change</div>
    <ul id="online_users" phx-update="stream">
      <li :for={{dom_id, %{id: id, metas: metas}} <- @streams.presences} id={dom_id}>
        {id} ({length(metas)})
      </li>
    </ul>
    """
  end

  def handle_info({Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end
end
