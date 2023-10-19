defmodule Pabric.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PabricWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Pabric.PubSub},
      # Start Finch
      {Finch, name: Pabric.Finch},
      # Start the Endpoint (http/https)
      PabricWeb.Endpoint
      # Start a worker by calling: Pabric.Worker.start_link(arg)
      # {Pabric.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pabric.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PabricWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
