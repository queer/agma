defmodule Agma.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      AgmaWeb.Telemetry,
      {Phoenix.PubSub, name: Agma.PubSub},
      AgmaWeb.Endpoint,
      {Singyeong.Client, Singyeong.parse_dsn("singyeong://agma:password@localhost:4567")},
      Singyeong.Producer,
      Agma.Consumer,
      Agma.Stats,
    ]

    opts = [strategy: :one_for_one, name: Agma.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AgmaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
