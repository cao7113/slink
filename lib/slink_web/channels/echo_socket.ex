defmodule SlinkWeb.EchoSocket do
  @moduledoc """
  Custom echo socket implementation.
  - https://hexdocs.pm/phoenix/1.8.1/Phoenix.Socket.Transport.html#module-example
  """

  @behaviour Phoenix.Socket.Transport
  require Logger

  @doc """
  This child_spec is called once when server started by Phoenix.Endpoint.Supervisor
  - deps/phoenix/lib/phoenix/endpoint/supervisor.ex
  """
  def child_spec(_opts) do
    # We won't spawn any process, so let's ignore the child spec
    Logger.debug("#{__MODULE__} child_spec called")
    :ignore
  end

  def connect(state) do
    # Callback to retrieve relevant data from the connection.
    # The map contains options, params, transport and endpoint keys.
    Logger.debug("connect called")
    {:ok, state}
  end

  def init(state) do
    # Now we are effectively inside the process that maintains the socket.
    Logger.debug("init called")
    {:ok, state}
  end

  def handle_in({msg, opcode: opcode} = frame, state) when opcode in [:text, :binary] do
    Logger.debug("handle_in frame: #{frame |> inspect}")
    {:reply, :ok, {opcode, msg}, state}
  end

  def handle_in(frame, state) do
    Logger.debug("handle_in unknown frame: #{frame |> inspect}")
    {:ok, state}
  end

  def handle_info(info, state) do
    Logger.debug("handle_info called with #{info |> inspect}")
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end
end
