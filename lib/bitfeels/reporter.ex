defmodule Bitfeels.Reporter do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:events])
  end

  def init(events) do
    :ets.new(:bitfeels_events, [:named_table, :public, :bag, {:write_concurrency, true}])

    :telemetry.attach_many("bitfeels-reporter", events, &handle_event/4, nil)

    {:ok, events}
  end

  defp handle_event([:bitfeels, :pipeline, :source] = event, measurements, metadata, _config) do
    data = {
      event_key(event),
      measurements.id,
      metadata.time
    }

    :ets.insert(:bitfeels_events, data)
  end

  defp handle_event([:bitfeels, :pipeline, :sentiment] = event, measurements, metadata, _config) do
    data = {
      event_key(event),
      measurements.id,
      measurements.score,
      metadata.time,
    }

    :ets.insert(:bitfeels_events, data)
  end

  defp event_key(event_name) do
    event_name |> Enum.map(&Atom.to_string/1) |> Enum.join("_")
  end
end
