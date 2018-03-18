defmodule ExFeelsWeb.FeelController do
  use ExFeelsWeb, :controller

  alias ExFeels.{Feel, Stat}
  alias ExFeels.Twitter.{Tweet, User}

  def feels(conn, params) do
    counts = all_counts()
    page = feels_by_page(params["page"])
    feels = group_by_tweet(page.entries)

    render(conn, "feel.html",
      counts: counts,
      page: page,
      feels: feels
    )
  end

  defp all_counts() do
    %{
      feels: Feel.count(),
      tweets: Tweet.count(),
      users: User.count(),
      stats: Stat.count()
    }
  end

  defp group_by_tweet(feels) do
    feels
    |> Enum.group_by(&(&1.tweet))
    |> Enum.into([])
  end

  defp feels_by_page(current_page, page_size \\ 24)

  defp feels_by_page(nil, _), do: feels_by_page(1)

  defp feels_by_page(current_page, page_size) do
    Feel.all(page: current_page, page_size: page_size)
  end
end
