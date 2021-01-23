defmodule Agma.Docker do
  use Tesla
  alias Agma.Docker.Container
  alias Agma.Utils

  plug Tesla.Middleware.BaseUrl, "http+unix://%2Fvar%2Frun%2Fdocker.sock/v1.41"
  plug Tesla.Middleware.Headers, [{"content-type", "application/json"}]
  plug Tesla.Middleware.JSON

  def containers do
    case get("/containers/json?all=1") do
      {:ok, %Tesla.Env{body: body}} ->
        containers =
          body
          |> Utils.snake()
          |> Enum.map(&Utils.atomify(&1, [:networks]))
          |> Enum.filter(&("/postgres_ppl-moe" in &1[:names]))
          |> Enum.map(&Container.from/1)
          |> IO.inspect(pretty: true, label: "### CONTAINER ###")

        {:ok, containers}

      {:error, _} = e ->
        e
    end
  end

  def running_containers do
    {:ok, containers} = containers()
    Enum.filter containers, fn container -> Map.get(container, "State", "exited") == "running" end
  end
end
