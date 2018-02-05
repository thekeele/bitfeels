defmodule ExFeelsWeb.TwitterApi.Fetch do
  @moduledoc false

  use GenServer

  @fetch_interval Application.get_env(:ex_feels, :twitter)[:fetch_interval]

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
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
    case ExFeelsWeb.TwitterApi.search_bitcoin() do
      :error -> IO.puts "error contacting twitter"

      :empty -> IO.puts "empty response from twitter"

      tweets -> IO.puts "found #{length(tweets)} tweets"
    end
  end

  defp generate_feels() do
    ExFeels.Feel.generate()
  end

  defp schedule_work() do
    Process.send_after(self(), :fetch, @fetch_interval)
  end
end
