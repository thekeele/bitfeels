defmodule ExFeelsWeb.TwitterApi do
  @moduledoc false

  alias ExFeelsWeb.TwitterApi.{Auth, Request, Response}
  alias ExFeels.Twitter.Tweet

  @stream_api "https://stream.twitter.com/1.1"

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

  def stream_statuses(to: stream_server) do
    url = @stream_api <> "/statuses/filter.json"
    params = %{"track" => "twitter"}
    headers = ["Authorization": Auth.oauth_header("GET", url, params)]
    opts = [{:async, :once}, {:stream_to, stream_server}]

    url
    |> append_query_params(params)
    |> :hackney.get(headers, "", opts)
  end

  defp append_query_params(url, params), do: url <> "?#{URI.encode_query(params)}"
end
