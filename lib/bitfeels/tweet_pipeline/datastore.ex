defmodule Bitfeels.TweetPipeline.Datastore do
  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:consumer, :ok, subscribe_to: [{Bitfeels.TweetPipeline.Sentiment, opts}]}
  end

  def handle_events(tweets, _from, :ok) do
    for {tweet_id, _tweet} <- tweets do
      IO.puts "persisting tweet.... #{tweet_id}"
      :timer.sleep(2_000)
    end

    {:noreply, [], :ok}
  end
end
