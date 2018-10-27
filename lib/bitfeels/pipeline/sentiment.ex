defmodule Bitfeels.Pipeline.Sentiment do
  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:producer_consumer, :ok, subscribe_to: [{Bitfeels.Source, opts}]}
  end

  def handle_events(events, _from, :ok) do
    # simulate network request time for sentiment
    :timer.sleep(3_000)

    {:noreply, events, :ok}
  end
end
