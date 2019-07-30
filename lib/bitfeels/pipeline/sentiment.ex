defmodule Bitfeels.Pipeline.Sentiment do
  use GenStage

  alias Bitfeels.Tweet.{Parser, Sentiment}

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:consumer, opts, subscribe_to: [{Bitfeels.Pipeline.Dispatcher, opts}]}
  end

  def handle_events(tweets, _from, opts) do
    for %{"id" => _} = status <- tweets do
      tweet = Parser.parse_to_tweet(status)

      tweet_with_sentiment =
        tweet
        |> Sentiment.sentiment_analysis()
        |> Sentiment.put_sentiment_score(tweet)

      send(opts[:sink], {:tweet, {tweet["id"], tweet_with_sentiment}})
    end

    {:noreply, [], opts}
  end
end
