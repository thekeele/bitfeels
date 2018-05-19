defmodule Twitter do
  @moduledoc """
  Twitter API
  """
  defdelegate search(params), to: Twitter.Search
  defdelegate start_streaming(opts \\ [chunk_rate: 5_000]), to: Twitter.Stream
  defdelegate stop_streaming(), to: Twitter.Stream
  defdelegate get_tweets(), to: Twitter.Stream
end
