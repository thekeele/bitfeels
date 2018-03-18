defmodule ExFeelsWeb.TwitterApi do
  @moduledoc false

  alias ExFeelsWeb.TwitterApi.{Request, Response}
  alias ExFeels.Twitter.Tweet

  def account_settings() do
    case Request.get("/account/settings.json") do
      {:ok, resp} ->
        Map.take(resp, ["language", "screen_name", "time_zone"])

      error -> error
    end
  end

  def search(params \\ %{}) when is_map(params) do
    case Request.get("/search/tweets.json", params) do
      {:ok, %{"statuses" => statuses}} ->
        statuses
        |> Response.parse_to_tweets()
        |> Tweet.create_all()

      {:error, _} -> :error

      [] -> :empty
    end
  end
end
