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

  defdelegate search(search_opts \\ @search_opts), to: Twitter.Search
end
