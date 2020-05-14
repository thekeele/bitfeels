defmodule Bitfeels.Tweet.Sentiment do

  def sentiment_analysis(tweets) do
    senpy = Application.get_env(:bitfeels, :sentiment)
    data = %{"model" => senpy[:model], "tweets" => tweets}

    url = senpy[:url]
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(data)
    opts = [:with_body]

    request_time = System.os_time(:microsecond)

    case :hackney.post(url, headers, body, opts) do
      {:ok, 200, _headers, resp} ->
        response_time = System.os_time(:microsecond) - request_time
        measurements = %{senpy_response_time: response_time, time: System.os_time(:microsecond)}
        :telemetry.execute([:bitfeels, :tweet, :sentiment], measurements)

        Jason.decode!(resp)["tweets"]

      _error -> tweets
    end
  end
end
