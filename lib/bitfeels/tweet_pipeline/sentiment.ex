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
        sentiment = sentiment_analysis(tweet)
        IO.puts "sentiment.... #{tweet_id}:#{sentiment}"

        {tweet_id, Map.put(tweet, "sentiment", sentiment)}
      end

    {:noreply, tweets, :ok}
  end

  def sentiment_analysis(tweet) do
    text = tweet["text"]
    url = "http://localhost:1337/score"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(%{"text" => text})
    opts = [:with_body]

    case :hackney.post(url, headers, body, opts) do
      {:ok, 200, _headers, resp} ->
        %{"sentiment" => [sentiment]} = Jason.decode!(resp)
        sentiment

      error ->
        IO.inspect(error, label: "error")
        nil
    end
  end
end
