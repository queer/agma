defmodule Agma.Stats do
  use GenServer
  alias Agma.Docker
  require Logger

  def start_link(opts) do
    GenServer.start_link __MODULE__, opts, name: __MODULE__
  end

  def container_names do
    Docker.containers()
    |> elem(1)
    |> Enum.map(&(&1.names))
  end

  def container_ids do
    Docker.containers()
    |> elem(1)
    |> Enum.map(&(&1.id))
  end

  def init(opts) do
    Logger.info "[STATS] I'm currently mangling: #{inspect Enum.zip(container_ids(), container_names()), pretty: true}"
    tick()
    {:ok, opts}
3  end

  def handle_info(:tick, state) do
    cpus = :erlang.system_info :logical_processors
    cpu_util = :cpu_sup.util()

    %{
      total_memory: mem_total,
      free_memory: mem_free,
    } = Map.new :memsup.get_system_memory_data()

    Singyeong.Client.update_metadata %{
      cpu_count: %{
        type: "integer",
        value: cpus,
      },
      cpu_util: %{
        type: "float",
        value: cpu_util,
      },
      mem_total: %{
        type: "integer",
        value: mem_total,
      },
      mem_free: %{
        type: "integer",
        value: mem_free,
      },
    }
    tick()
    {:noreply, state}
  end

  defp tick() do
    Process.send_after self(), :tick, 100
  end
end
