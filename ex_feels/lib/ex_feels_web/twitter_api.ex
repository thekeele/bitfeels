defmodule ExFeelsWeb.TwitterApi do
  @moduledoc false

  use Timex

  alias ExFeelsWeb.TwitterApi.{HTTP, Response}
  alias ExFeels.Twitter.Tweet

  def account_settings() do
    case HTTP.request("GET", "/account/settings.json") do
      {:ok, resp} ->
        Map.take(resp, ["language", "screen_name", "time_zone"])

      error -> error
    end
  end

  def search(params) do
    case HTTP.request("GET", "/search/tweets.json", params) do
      {:ok, %{"statuses" => statuses}} ->
        Response.parse_to_tweets(statuses)

      error -> error
    end
  end

  def search_bitcoin() do
    query = URI.encode("bitcoin since:#{last_month()}")

    params = %{
      "q" => query,
      "count" => 10,
      "lang" => "en",
      "result_type" => "popular",
      "tweet_mode" => "extended" # for 280 char tweets
    } |> IO.inspect(label: "search params")

    case search(params) do
      {:error, _} -> :error

      [] -> :empty

      tweets -> Tweet.create_all(tweets)
    end
  end

  defp last_month() do
    %{year: year, month: month, day: day} =
      Timex.now |> Timex.shift(months: -1)

    "#{year}-#{month}-#{day}"
  end
end
