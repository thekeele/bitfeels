defmodule ExFeelsWeb.TwitterApi do

  alias ExFeelsWeb.TwitterApi.{HTTP, Response}

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
end
