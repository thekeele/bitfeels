defmodule ExFeels.Feel.Fetcher do
  use GenServer
  use Timex

  require Logger

  alias ExFeels.{Feel, Twitter.Tweet}

  def start_link(opts \\ [{"bitcoin", [months: -1]}]) do
    Logger.info fn ->
      """
      starting #{__MODULE__} [opts: #{inspect opts}]
      """
    end

    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    schedule_work(0)

    {:ok, opts}
  end

  def handle_info(:search, opts) do
    search_tweets(opts)

    Enum.map([:binary_classifier, :time_series], &generate_feels/1)

    schedule_work()

    {:noreply, opts}
  end

  defp search_tweets([{currency, window}]) do
    params =
      %{
        "q" => URI.encode("#{currency} since:#{last(window)}"),
        "count" => 10,
        "lang" => "en",
        "result_type" => "popular",
        "tweet_mode" => "extended" # for 280 char tweets
      }

    Logger.info fn ->
      """
      searching twitter for...
      %{
        "q" => #{params["q"]},
        "count" => #{params["count"]},
        "lang" => #{params["lang"]},
        "result_type" => #{params["result_type"]},
        "tweet_mode" => #{params["tweet_mode"]}
      }
      """
    end

    params
    |> Twitter.search()
    |> Tweet.create_all()
    |> case do
      [] ->
        :ok

      tweets ->
        {:ok, tweets}
    end
  end

  defp last(search_window) do
    %{year: year, month: month, day: day} = Timex.now |> Timex.shift(search_window)

    "#{year}-#{month}-#{day}"
  end

  defp generate_feels(py_feel) do
    Logger.info fn ->
      """
      firing #{py_feel} feel
      """
    end

    Feel.generate_feels(py_feel)
  end

  defp schedule_work(in_ms \\ 1 * 1000 * 60 * 60),
    do: Process.send_after(self(), :search, in_ms)
end
