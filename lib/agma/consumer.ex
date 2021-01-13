defmodule Agma.Consumer do
  use Singyeong.Consumer

  def start_link do
    Consumer.start_link __MODULE__
  end

  def handle_event(event) do
    IO.inspect event, pretty: true
    :ok
  end
end
