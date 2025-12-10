defmodule SlinkWeb.ChatSocket do
  @moduledoc """
  Demo Phoenix.Socket

  iex>  Web.ChatSocket.__channel__("room:*")

  ## Links
  - https://hexdocs.pm/phoenix/channels.html#tying-it-all-together
  """

  # final partitions = Keyword.get(opts, :partitions, System.schedulers_online())
  use Phoenix.Socket, log: :debug, partitions: 2
  require Logger

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels
  # Uncomment the following line to define a "room:*" topic
  # pointing to the `SlinkWeb.RoomChannel`:
  channel "room:*", SlinkWeb.RoomChannel

  # To create a channel file, use the mix task:
  #
  #     mix phx.gen.channel Room
  #
  # See the [`Channels guide`](https://hexdocs.pm/phoenix/channels.html)
  # for further details.

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error` or `{:error, term}`. To control the
  # response the client receives in that case, [define an error handler in the
  # websocket
  # configuration](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#socket/3-websocket-configuration).
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(_params, socket, connect_info) do
    # self() will be the socket.transport_id if is websocket connection
    # binding channel process is the socket.channel_pid

    user_token =
      connect_info
      |> Map.get(:session, %{})
      |> Map.get("user_token")

    {user, _} =
      if user_token do
        Slink.Accounts.get_user_by_session_token(user_token)
      end || {nil, nil}

    if user do
      {:ok, assign(socket, :current_user, user)}
    else
      {:error, "Unauthenticated user!"}
    end
  end

  # Socket IDs are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "chat_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.SlinkWeb.Endpoint.broadcast("chat_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  # called after connect callback
  @impl true
  def id(socket) do
    Logger.debug("user-socket id called")
    "chat_socket:#{socket.assigns.current_user.id}"
  end

  @doc """
  :error_handler - custom error handler for connection errors. If Phoenix.Socket.connect/3 returns an {:error, reason} tuple, the error handler will be called with the error reason. For WebSockets, the error handler must be a MFA tuple that receives a Plug.Conn, the error reason, and returns a Plug.Conn with a response.
  - https://hexdocs.pm/phoenix/1.8.1/Phoenix.Endpoint.html#socket/3-websocket-configuration
  """
  def handle_error(conn, reason) do
    Logger.error("user-socket connect error with reason: #{reason |> inspect}")
    Plug.Conn.send_resp(conn, 400, "Bad request: #{reason |> inspect}")
  end
end
