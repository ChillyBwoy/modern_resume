defmodule ModernResume.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ModernResumeWeb.Telemetry,
      ModernResume.Repo,
      {DNSCluster, query: Application.get_env(:modern_resume, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ModernResume.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ModernResume.Finch},
      # Start a worker by calling: ModernResume.Worker.start_link(arg)
      # {ModernResume.Worker, arg},
      # Start to serve requests, typically the last entry
      ModernResumeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ModernResume.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ModernResumeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
