defmodule ExFeels.FeelFetcher do
  use GenServer

  alias ExFeels.{Feel, Twitter.Tweet}

  def start_link(),
    do: GenServer.start_link(__MODULE__, %{})

  def init(search_opts) do
    schedule_work(0)

    {:ok, search_opts}
  end

  def handle_info(:search, search_opts) do
    search_tweets()

    Feel.generate_feels([:binary_classifier, :time_series])

    schedule_work()

    {:noreply, search_opts}
  end

  defp search_tweets() do
    Twitter.search()
    |> Tweet.parse_to_tweets()
    |> Tweet.create_all()
    |> case do
      [] -> :ok

      ex_feels_tweets -> {:ok, ex_feels_tweets}
    end
  end

  defp schedule_work(in_ms \\ 1 * 1000 * 60 * 60), do: Process.send_after(self(), :search, in_ms)
end
