defmodule ExFeelsWeb.TwitterApi.Search do

  use Timex

  def build_search_params(%{crypto: currency, search: window}) do
    query = URI.encode(
      "#{currency} since:#{last(window)}"
    )

    %{
      "q" => query,
      "count" => 10,
      "lang" => "en",
      "result_type" => "popular",
      "tweet_mode" => "extended" # for 280 char tweets
    }
  end

  defp last(search_window) do
    %{year: year, month: month, day: day} =
      Timex.now |> Timex.shift(search_window)

    "#{year}-#{month}-#{day}"
  end
end
