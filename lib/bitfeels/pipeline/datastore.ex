defmodule Bitfeels.Pipeline.Datastore do
  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:consumer, :ok, subscribe_to: [{Bitfeels.Pipeline.Sentiment, opts}]}
  end

  def handle_events(events, _from, :ok) do
    # simulate database insert time
    :timer.sleep(2_000)

    {:noreply, [], :ok}
  end
end
