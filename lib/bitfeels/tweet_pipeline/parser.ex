defmodule Bitfeels.TweetPipeline.Parser do
  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:producer_consumer, :ok, subscribe_to: [{Bitfeels.TweetSource, opts}]}
  end

  def handle_events(tweets, _from, :ok) do
    tweets =
      for {tweet_id, status} <- tweets do
        {tweet_id, Bitfeels.Tweet.parse_to_tweet(status)}
      end

    {:noreply, tweets, :ok}
  end
end
