defmodule ExFeelsWeb.TweetsController do
  use ExFeelsWeb, :controller

  alias ExFeelsWeb.TwitterApi

  def index(conn, params) do
    case TwitterApi.search(params) do
      {:error, _} ->
        render(conn, "index.json", tweets: [])

      [] ->
        render(conn, "index.json", tweets: [])

      tweets ->
        render(conn, "index.json", tweets: tweets)
    end
  end
end
