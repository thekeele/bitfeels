defmodule Bitfeels.TweetPipeline.Sentiment do
  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:producer_consumer, :ok, subscribe_to: [{Bitfeels.TweetPipeline.Parser, opts}]}
  end

  def handle_events(tweets, _from, :ok) do
    tweets =
      for {tweet_id, tweet} <- tweets do
        IO.puts "running sentiment analysis on #{tweet_id}"
        IO.inspect(tweet, label: "tweet")
        :timer.sleep(3_000)

        {tweet_id, tweet}
      end

    {:noreply, tweets, :ok}
  end
end
