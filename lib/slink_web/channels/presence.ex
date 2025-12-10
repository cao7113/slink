defmodule SlinkWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  - https://hexdocs.pm/phoenix/presence.html#usage-with-channels-and-javascript

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :slink,
    pubsub_server: Slink.PubSub
end
