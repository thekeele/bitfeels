defmodule ExFeelsWeb.Twitter do

  alias ExFeelsWeb.Twitter.{HTTP, Search}

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
        statuses
        |> Search.parse_to_tweets()
        |> IO.inspect(label: "tweets")

      error -> error
    end
  end
end
