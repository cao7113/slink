defmodule SlinkWeb.PresenceLive do
  @moduledoc """
  Tryp Presence with liveview

  Try
  - http://localhost:4000/play/online/alice
  - http://localhost:4000/play/online/alice

  ## Links
  - https://hexdocs.pm/phoenix/presence.html#usage-with-liveview
  """

  use Phoenix.Presence,
    otp_app: :slink,
    pubsub_server: Slink.PubSub

  ## helpers

  def list_online_users(),
    do: list("online_users") |> Enum.map(fn {_id, presence} -> presence end)

  def track_user(name, params), do: track(self(), "online_users", name, params)

  def subscribe(), do: Phoenix.PubSub.subscribe(Slink.PubSub, "proxy:online_users")

  ## callbacks

  def init(_opts) do
    {:ok, %{}}
  end

  def fetch(_topic, presences) do
    for {key, %{metas: [meta | metas]}} <- presences, into: %{} do
      # user can be populated here from the database here we populate
      # the name for demonstration purposes
      {key, %{metas: [meta | metas], id: meta.id, user: %{name: meta.id}}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
      msg = {__MODULE__, {:join, user_data}}
      Phoenix.PubSub.local_broadcast(Slink.PubSub, "proxy:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, user_data}}
      Phoenix.PubSub.local_broadcast(Slink.PubSub, "proxy:#{topic}", msg)
    end

    {:ok, state}
  end
end
