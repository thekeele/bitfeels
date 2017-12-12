defmodule ExFeelsWeb.Twitter do

  alias ExFeelsWeb.Twitter.HTTP

  def account_settings() do
    case HTTP.request("GET", "/account/settings.json") do
      {:ok, resp} ->
        Map.take(resp, ["language", "screen_name", "time_zone"])

      error -> error
    end
  end

  def search(params) do
    case HTTP.request("GET", "/search/tweets.json", params) do
      {:ok, resp} ->
        keys = ["created_at", "id", "text", "retweet_count", "favorite_count", "lang"]

        Enum.map(resp["statuses"], &Map.take(&1, keys))

      error -> error
    end
  end
end
