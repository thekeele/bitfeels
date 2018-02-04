defmodule ExFeelsWeb.TwitterApi.Fetch do
  use GenServer

  alias ExFeelsWeb.TwitterApi

  @fetch_interval Application.get_env(:ex_feels, :twitter)[:fetch_interval]

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    IO.puts "starting twitter api fetch and feel process"

    fetch_tweets()

    generate_feels()

    schedule_work()

    {:ok, state}
  end

  def handle_info(:fetch, state) do
    fetch_tweets()

    generate_feels()

    schedule_work()

    {:noreply, state}
  end

  defp fetch_tweets() do
    params = %{
      "q" => "bitcoin",
      "count" => 2,
      "lang" => "en",
      "tweet_mode" => "extended" # for 280 char tweets
    }

    IO.inspect params, label: "firing search with params"

    case TwitterApi.search(params) do
      {:error, _} ->
        IO.puts "response error"

      [] ->
        IO.puts "empty response"

      tweets ->
        IO.puts "found #{length(tweets)} tweets"

        create_all(tweets)
    end
  end

  defp schedule_work() do
    Process.send_after(self(), :fetch, @fetch_interval)
  end

  # domain crossing funs
  defp create_all(tweets) do
    ExFeels.Twitter.Tweet.create_all(tweets)
  end

  defp generate_feels() do
    ExFeels.Feel.generate()
  end
end
