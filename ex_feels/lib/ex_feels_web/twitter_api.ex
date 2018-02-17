defmodule ExFeelsWeb.TwitterApi do
  @moduledoc false

  alias ExFeelsWeb.TwitterApi.{Request, Response, Search}
  alias ExFeels.Twitter.Tweet

  def account_settings() do
    case Request.get("/account/settings.json") do
      {:ok, resp} ->
        Map.take(resp, ["language", "screen_name", "time_zone"])

      error -> error
    end
  end

  def search(params \\ %{}) when is_map(params) do
    search_params =
      params
      |> Search.build_search_params()
      |> IO.inspect(label: "search params")

    case Request.get("/search/tweets.json", search_params) do
      {:ok, %{"statuses" => statuses}} ->
        statuses
        |> Response.parse_to_tweets()
        |> Tweet.create_all()

      {:error, _} -> :error

      [] -> :empty
    end
  end
end
