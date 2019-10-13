defmodule Bitfeels.Pipeline.Source do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, :ok}
  end

  def handle_info({:tweet, from, event}, :ok) do
    event
    |> put_stream_metadata(from)
    |> fire_metric_event()
    |> Bitfeels.Pipeline.Dispatcher.notify()

    {:noreply, :ok}
  end

  defp put_stream_metadata(event, from) do
    [stream_key | _] = Registry.keys(Registry.Streams, from)
    [user, track] = String.split(stream_key, "_")
    Map.put(event, "stream", %{user: user, track: track})
  end

  defp fire_metric_event(%{"id" => id, "stream" => stream} = event) do
    measurements = %{id: id}
    metadata = %{time: System.os_time(:millisecond), stream: stream}
    :telemetry.execute([:bitfeels, :pipeline, :source], measurements, metadata)

    event
  end
end
