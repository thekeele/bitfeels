defmodule ExFeelsWeb.TwitterApi.Worker do
  @moduledoc false

  use GenServer

  @search_interval 1 * 1000 * 60 * 60 # one hour
  # @search_interval 1 * 1000 * 60 # one minute

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    search_tweets()

    generate_feels()

    schedule_work()

    {:ok, state}
  end

  def handle_info(:search, state) do
    search_tweets()

    generate_feels()

    schedule_work()

    {:noreply, state}
  end

  defp search_tweets() do
    case ExFeelsWeb.TwitterApi.search() do
      :error -> IO.puts "error contacting twitter"

      :empty -> IO.puts "empty response from twitter"

      tweets -> IO.puts "found #{length(tweets)} tweets"
    end
  end

  defp generate_feels() do
    ExFeels.Feel.generate()
  end

  defp schedule_work() do
    Process.send_after(self(), :search, @search_interval)
  end
end
