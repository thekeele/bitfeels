defmodule Bitfeels.Reporter do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    :telemetry.attach_many("bitfeels-reporter", opts[:events], &handle_event/4, opts[:sink])

    {:ok, opts}
  end

  defp handle_event([:bitfeels, :pipeline, :source] = event, measurements, metadata, sink) do
    data = {
      event_key(event),
      measurements.id,
      metadata.time
    }

    send(sink, {:bitfeels_event, data})
  end

  defp handle_event([:bitfeels, :pipeline, :sentiment] = event, measurements, metadata, sink) do
    data = {
      event_key(event),
      measurements.id,
      measurements.score,
      metadata.time,
    }

    send(sink, {:bitfeels_event, data})
  end

  defp event_key(event_name) do
    event_name |> Enum.map(&Atom.to_string/1) |> Enum.join("_")
  end
end
