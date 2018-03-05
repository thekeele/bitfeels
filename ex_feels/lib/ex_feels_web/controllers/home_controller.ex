defmodule ExFeelsWeb.HomeController do
  use ExFeelsWeb, :controller

  alias ExFeels.{Feel, Stat, Twitter.Tweet, Twitter.User}

  def home(conn, params) do
    counts = %{
        :feels => Feel.count(),
        :tweets => Tweet.count(),
        :users => User.count(),
        :stats => Stat.count()
    }

    current_page = params["page"] || 1

    page = Feel.all(page: current_page, page_size: 24)

    render(conn, "home.html",
      page: page,
      feels: group_by_tweet(page.entries),
      counts: counts
    )
  end

  defp group_by_tweet(feels) do
    feels
    |> Enum.group_by(&(&1.tweet))
    |> Enum.into([])
  end
end
