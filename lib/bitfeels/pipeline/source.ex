defmodule Bitfeels.Pipeline.Source do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, :ok}
  end

  def handle_info({:tweet, event}, :ok) do
    fire_metric_event(event)

    :ok = Bitfeels.Pipeline.Dispatcher.notify(event)

    {:noreply, :ok}
  end

  defp fire_metric_event(%{"id" => id}) do
    measurements = %{id: id}
    metadata = %{time: System.os_time(:millisecond)}
    :telemetry.execute([:bitfeels, :pipeline, :source], measurements, metadata)
  end
end
