defmodule ExFeelsWeb.TwitterApi.Search do

  use Timex

  def build_search_params(%{crypto: currency, search: window})
      when is_binary(currency) do
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
  def build_search_params(_),
    do: build_search_params(%{crypto: "bitcoin", search: [months: -1]})

  defp last(search_window) do
    %{year: year, month: month, day: day} =
      Timex.now |> Timex.shift(search_window)

    "#{year}-#{month}-#{day}"
  end
end
