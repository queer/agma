defmodule Agma.Consumer do
  use Singyeong.Consumer
  alias Agma.Docker
  alias Agma.Docker.Labels
  alias Mahou.Message
  alias Mahou.Message.{
    ChangeContainerStatus,
    CreateContainer,
  }
  require Logger

  def start_link do
    Consumer.start_link __MODULE__
  end

  def handle_event({:send, _nonce, event}) do
    process event
  end

  def handle_event({:broadcast, _nonce, event}) do
    process event
  end

  defp process(event) do
    event
    |> Message.parse
    |> inspect_ts
    |> Map.get(:payload)
    |> process_event
    :ok
  end

  defp inspect_ts(%Message{ts: ts} = m) do
    if abs(ts - :os.system_time(:millisecond)) > 1_000 do
      Logger.warn "pig: ts: clock drift > 1000ms"
    end
    m
  end

  def process_event(%CreateContainer{apps: apps}) do
    Logger.info "deploy: apps:\n* #{apps |> Enum.map(&("#{&1.namespace}:#{&1.name} -> #{&1.image}")) |> Enum.join("\n* ")}"
    Logger.info "deploy: apps: #{Enum.count apps} total"
    for app <- apps do
      name = Docker.app_name app
      Docker.create app.image, name, %{Labels.namespace() => app.namespace}
      Logger.info "deploy: app: created #{name}"
    end
    for app <- apps do
      name = Docker.app_name app
      Docker.start name
      Logger.info "deploy: app: started #{name}"
    end
  end

  # TODO: Use id somewhere S:
  def process_event(%ChangeContainerStatus{id: _id, name: name, namespace: ns, command: cmd}) do
    app = Docker.app_name name, ns
    Logger.info "status: app: #{app}: sending :#{cmd}"
    case cmd do
      :stop -> Docker.stop app
      :kill -> Docker.kill app
    end
  end
end
