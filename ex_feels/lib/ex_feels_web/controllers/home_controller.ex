defmodule ExFeelsWeb.HomeController do
  use ExFeelsWeb, :controller

  alias ExFeels.{Feel, Twitter.Tweet, Twitter.User}

  def home(conn, _params) do
    feels = group_by_tweet(Feel.all())
    counts = %{
        :feels => Feel.count(),
        :tweets => Tweet.count(),
        :users => User.count()
    }

    render(conn, "home.html", feels: feels, counts: counts)
  end

  defp group_by_tweet(feels) do
    feels
    |> Enum.group_by(&(&1.tweet))
    |> Enum.into([])
    |> Enum.sort(&(elem(&1, 0).id >= elem(&2, 0).id))
  end
end
