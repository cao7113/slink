defmodule PhxHelper do
  @moduledoc """
  Phoenix Helpers

  - https://hexdocs.pm/phoenix/Phoenix.Debug.html
  """
  @compile {:no_warn_undefined, Phoenix.Debug}

  # if Code.ensure_loaded?(Phoenix), do: :ok
  def hi, do: :ok

  @otp_app :slink
  # NOTE: endport is a plug with nested plug-chain built by Plug.Builder
  @endpoint SlinkWeb.Endpoint
  # Slink.Supervisor

  def app_sup(mod \\ Slink.Supervisor) do
    Process.whereis(mod)
  end

  def server?, do: Phoenix.Endpoint.server?(@otp_app, @endpoint)
  def server_info(scheme \\ :http), do: @endpoint.server_info(scheme)
  def ep_sup(ep \\ @endpoint), do: Process.whereis(ep)
  def ep_children(sup \\ ep_sup()), do: Supervisor.which_children(sup)

  def bandit_server(ep \\ @endpoint) do
    with {:ok, pid} <- Bandit.PhoenixAdapter.bandit_pid(ep) do
      pid
    end
  end

  def pubsub_server, do: @endpoint.config(:pubsub_server)
  # Phoenix.Endpoint.Supervisor.start_link(@otp_app, __MODULE__, opts)
  def child_spec(opts \\ []), do: @endpoint.child_spec(opts)

  @ep_keys [
    :adapter,
    :server,
    :http,
    :https,
    :url,
    :static_url,
    :log_access_url,
    :cache_static_manifest_latest,
    :live_reload,
    :live_view,
    :pubsub_server,
    :drainer,
    :render_errors,
    :watchers,
    :force_watchers
  ]

  @doc """
  Endpoin config

  - Ep.struct_url()
  - Ep.url()
  - Ep.config(:http),
  - Ep.config(:port)

  -  https://hexdocs.pm/phoenix/1.8.1/Phoenix.Endpoint.html#module-runtime-configuration
  """
  def config(key \\ :adapter, opts \\ []) when is_atom(key) do
    ep_module = Keyword.get(opts, :ep, @endpoint)
    ep_module.config(key)
  end

  def configs(opts \\ []) when is_list(opts) do
    ep_module = Keyword.get(opts, :ep, @endpoint)
    keys = Keyword.get(opts, :keys, @ep_keys)

    keys
    |> Enum.map(fn k ->
      {k, ep_module.config(k)}
    end)
    |> Enum.sort()
  end

  # def sign_token(salt, data \\ nil, ctx \\ :test) do
  #   Phoenix.Token.sign(ctx, salt, data)
  # end

  # def verify_token(salt, token, opts \\ [], ctx \\ :test) do
  #   Phoenix.Token.verify(ctx, salt, token, opts)
  # end

  ## Phoenix Sockets and Channels process

  @doc """
  Returns a list of all currently connected Phoenix.Socket transport processes.

  [
    %{
      id: "chat_socket:3",
      module: SlinkWeb.ChatSocket,
      pid: #PID<0.1118.0>
    },
    %{id: nil, module: Phoenix.LiveReloader.Socket, pid: #PID<0.1127.0>}
  ]
  """
  def sockets(opts \\ []) do
    with_reloader = Keyword.get(opts, :with_reloader, false)

    Phoenix.Debug.list_sockets()
    |> Enum.filter(fn %{module: mod} ->
      case mod do
        Phoenix.LiveReloader.Socket -> with_reloader
        _ -> true
      end
    end)
  end

  def ep_sockets, do: @endpoint.__sockets__()

  def channels_of_socket(socket_pid \\ rand_socket_pid()) do
    Phoenix.Debug.list_channels(socket_pid)
    |> case do
      {:ok, channels} -> channels
      other -> other
    end
  end

  def socket_of_channel(channel_pid), do: Phoenix.Debug.socket(channel_pid)

  def rand_socket_pid, do: rand_socket() |> Map.get(:pid)
  def rand_socket, do: sockets() |> Enum.random()
end
