defmodule ExFeels.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ExFeels.Repo, []),
      supervisor(ExFeelsWeb.Endpoint, []),
      worker(ExFeels.FeelFetcher, [])
      worker(ExFeelsWeb.TwitterApi.Streamer, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    opts = [strategy: :one_for_one, name: ExFeels.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ExFeelsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
