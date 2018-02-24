defmodule ExFeelsWeb.TwitterApi.Worker do
  @moduledoc false

  use GenServer

  require Logger

  alias ExFeelsWeb.TwitterApi.Search

  @search_interval 1 * 1000 * 60 * 60 # one hour
  # @search_interval 1 * 1000 * 60 # one minute

  @py_feels [:binary_classifier, :time_series]

  def start_link() do
    module = __MODULE__
    state = {"bitcoin", [months: -1]}

    Logger.info fn ->
      """
      starting GenServer #{module}
      with state #{elem(state, 0)}
      """
    end

    GenServer.start_link(module, state)
  end

  def init(state) do
    search_tweets(state)

    Enum.map(@py_feels, &generate_feels(&1))

    schedule_work()

    {:ok, state}
  end

  def handle_info(:search, state) do
    search_tweets(state)

    Enum.map(@py_feels, &generate_feels(&1))

    schedule_work()

    {:noreply, state}
  end

  defp search_tweets({currency, window}) do
    params =
      %{
        crypto: currency,
        search: window
      }
      |> Search.build_search_params()

    Logger.info fn ->
      """
      twitter search params

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
    |> ExFeelsWeb.TwitterApi.search()
    |> case do
      :error ->
        Logger.info fn ->
          """
          error contacting twitter
          """
        end

      :empty ->
        Logger.info fn ->
          """
          empty response from twitter
          """
        end

      tweets ->
        Logger.info fn ->
          """
          found #{length(tweets)} tweets
          """
        end
    end
  end

  defp generate_feels(py_feel) do
    Logger.info fn ->
      """
      starting process #{py_feel}
      """
    end

    ExFeels.Feel.generate_feels(py_feel)
  end

  defp schedule_work() do
    Logger.info fn ->
      """
      sending process a message in #{@search_interval}
      """
    end

    Process.send_after(self(), :search, @search_interval)
  end
end
