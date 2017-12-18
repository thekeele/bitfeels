defmodule ExFeelsWeb.TweetsController do
  use ExFeelsWeb, :controller

  alias ExFeelsWeb.TwitterApi
  alias ExFeels.Twitter.Tweet

  def index(conn, _params) do
    case TwitterApi.search(%{"q" => "bitcoin", "count" => 1}) do
      {:error, _} ->
        render(conn, "index.json", tweets: [])

      [] ->
        render(conn, "index.json", tweets: [])

      tweets ->
        Tweet.create_all(tweets)

        render(conn, "index.json", tweets: tweets)
    end
  end
end
