defmodule Twitter do
  @moduledoc """
  Twitter API
  """

  @search_opts %{
    window: [months: -1],
    params: %{
      "q" => "bitcoin",
      "count" => 10,
      "lang" => "en",
      "result_type" => "popular",
      "tweet_mode" => "extended"
    }
  }

  @stream_opts [
    chunk_rate: 2_000,
    query_params: %{
      "track" => "bitcoin,crypto,currency,ethereum",
      "lang" => "en",
      "filter_level" => "none",
      "stall_warnings" => true,
      "tweet_mode" => "extended",
      "result_type" => "popular"
    }
  ]

  defdelegate search(search_opts \\ @search_opts), to: Twitter.Search
  defdelegate start_streaming(stream_opts \\ @stream_opts), to: Twitter.Stream
  defdelegate stop_streaming(), to: Twitter.Stream
  defdelegate get_tweets(), to: Twitter.Stream
  defdelegate get_latest_tweet(), to: Twitter.Stream
  defdelegate take_tweets_from_stream(amount \\ 5), to: Twitter.Stream
  defdelegate get_stream_status(), to: Twitter.Stream
end
