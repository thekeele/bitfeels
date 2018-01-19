defmodule ExFeelsWeb.HomeController do
  use ExFeelsWeb, :controller

  alias ExFeels.Feel

  def home(conn, _params) do
    feels = group_by_tweet(Feel.all())

    render(conn, "home.html", feels: feels)
  end

  defp group_by_tweet(feels) do
    feels
    |> Enum.group_by(&(&1.tweet))
    |> Enum.into([])
    |> Enum.sort(&(elem(&1, 0).created_at >= elem(&2, 0).created_at))
  end
end
