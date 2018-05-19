defmodule Twitter do
  alias Twitter.OAuth, as: Auth

  @rest_api "https://api.twitter.com/1.1"
  @stream_api "https://stream.twitter.com/1.1"

  def account_settings() do
    url = @rest_api <> "/account/settings.json"
    headers = [{"Authorization", Auth.oauth_header(:get, url)}]

    case :hackney.get(url, headers, "", [:with_body]) do
      {:ok, 200, _headers, resp_body} ->
        resp_body
        |> Poison.decode!()
        |> Map.take(["language", "screen_name", "time_zone"])

      {:ok, status, _headers, body} when status > 200 ->
        {:error, Poison.decode!(body)}

      error ->
        {:error, "#{inspect error}"}
    end
  end

  def search(params) when is_map(params) do
    url = @rest_api <> "/search/tweets.json"
    headers = [{"Authorization", Auth.oauth_header(:get, url, params)}]

    response =
      url
      |> append_query_params(params)
      |> :hackney.get(headers, "", [:with_body])
      |> case do
        {:ok, 200, _headers, resp_body} ->
          Poison.decode(resp_body)

        {:ok, status, _headers, resp_body} when status > 200 ->
          {:error, Poison.decode!(resp_body)}

        error ->
          {:error, "#{inspect error}"}
      end

    case response do
      {:ok, %{"statuses" => statuses}} ->
        parse_to_tweets(statuses)

      [] ->
        []

      error ->
        IO.inspect error, label: "twitter search error"
        []
    end
  end

  def stream_statuses(to: stream_server) do
    url = @stream_api <> "/statuses/filter.json"
    params = %{"track" => "twitter"}
    headers = ["Authorization": Auth.oauth_header(:get, url, params)]
    opts = [{:async, :once}, {:stream_to, stream_server}]

    url
    |> append_query_params(params)
    |> :hackney.get(headers, "", opts)
  end

  def parse_to_tweets(statuses) do
    Enum.map(statuses, fn status ->
      status = status["retweeted_status"] || status

      status
      |> take_status_data()
      |> Map.put("hashtags", take_hashtags_data(status["entities"]["hashtags"]))
      |> Map.put("user", take_user_data(status["user"]))
    end)
  end

  defp take_status_data(status) do
    keys = ["created_at", "id", "full_text", "retweet_count", "favorite_count", "lang"]

    Map.take(status, keys)
  end

  defp take_hashtags_data(hashtags), do: Enum.map(hashtags, & &1["text"])

  defp take_user_data(user) do
    keys = [
      "id", "screen_name", "followers_count", "favourites_count", "time_zone", "verified", "statuses_count"
    ]

    Map.take(user, keys)
  end

  defp append_query_params(url, params), do: url <> "?#{URI.encode_query(params)}"
end
