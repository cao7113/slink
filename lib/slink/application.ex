defmodule Slink.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SlinkWeb.Telemetry,
      Slink.Repo,
      {DNSCluster, query: Application.get_env(:slink, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Slink.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Slink.Finch},
      # Start a worker by calling: Slink.Worker.start_link(arg)
      # {Slink.Worker, arg},
      # Start to serve requests, typically the last entry
      SlinkWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Slink.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SlinkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
