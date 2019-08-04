defmodule Bitfeels.Tweet.Sentiment do

  def sentiment_analysis(tweets) do
    senpy = Application.get_env(:bitfeels, :sentiment)
    data = %{"model" => senpy[:model], "tweets" => tweets}

    url = senpy[:url]
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(data)
    opts = [:with_body]

    case :hackney.post(url, headers, body, opts) do
      {:ok, 200, _headers, resp} -> Jason.decode!(resp)["tweets"]
      _error -> tweets
    end
  end
end
