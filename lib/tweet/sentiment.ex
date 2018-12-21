defmodule Bitfeels.Tweet.Sentiment do

  def sentiment_analysis(%{"id" => _, "text" => _} = tweet) do
    url = "http://localhost:5000/score"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(%{"model" => "spacy", "tweets" => [tweet]})
    opts = [:with_body]

    case :hackney.post(url, headers, body, opts) do
      {:ok, 200, _headers, resp} -> Jason.decode!(resp)["tweets"]
      error -> error
    end
  end

  def put_sentiment_score(sentiment, tweet) do
    case sentiment do
      [%{"sentiment" => sentiment, "score" => score} | _] ->
        tweet
        |> Map.put("sentiment", sentiment)
        |> Map.put("score", score)

      _ ->
        tweet
    end
  end
end
