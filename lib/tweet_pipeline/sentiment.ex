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
        %{"tweets" => tweets} = sentiment_analysis(tweet)
        %{"sentiment" => sentiment, "score" => score} = List.first(tweets)
        IO.puts "sentiment.... #{tweet_id}:#{sentiment}:#{score}"

        tweets
      end

    {:noreply, tweets, :ok}
  end

  defp sentiment_analysis(%{"id" => _, "text" => _} = tweet) do
    url = "http://localhost:1337/score"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(%{"tweets" => [tweet]})
    opts = [:with_body]

    case :hackney.post(url, headers, body, opts) do
      {:ok, 200, _headers, resp} ->
        Jason.decode!(resp)

      {:ok, 400, _headers, resp} ->
        IO.inspect(resp, label: "error")
        nil

      {:ok, 403, _headers, resp} ->
        IO.inspect(resp, label: "error")
        nil

      error ->
        IO.inspect(error, label: "error")
        nil
    end
  end
end
