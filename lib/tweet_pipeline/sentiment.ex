defmodule Bitfeels.TweetPipeline.Sentiment do
  use GenStage

  require Logger

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:producer_consumer, opts, subscribe_to: [{Bitfeels.TweetPipeline.Parser, opts}]}
  end

  def handle_events(tweets, _from, opts) do
    tweets_with_sentiment =
      for {tweet_id, tweet} <- tweets do
        tweet_with_sentiment =
          tweet
          |> sentiment_analysis()
          |> put_sentiment_score(tweet)

        {tweet_id, tweet_with_sentiment}
      end

    {:noreply, tweets_with_sentiment, opts}
  end

  defp sentiment_analysis(%{"id" => _, "text" => _} = tweet) do
    url = "http://localhost:1337/score"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(%{"tweets" => [tweet]})
    opts = [:with_body]

    case :hackney.post(url, headers, body, opts) do
      {:ok, 200, _headers, resp} ->
        Jason.decode!(resp)["tweets"]

      error ->
        Logger.error("#{inspect(error)}")
    end
  end

  defp put_sentiment_score(tweets, tweet) do
    case tweets do
      [%{"sentiment" => sentiment, "score" => score} | _] ->
        tweet
        |> Map.put("sentiment", sentiment)
        |> Map.put("score", score)

      _ ->
        tweet
    end
  end
end
