defmodule ExFeelsWeb.HomeController do
  use ExFeelsWeb, :controller

  alias ExFeels.Feel

  def home(conn, params) do
    current_page = params["page"] || 1

    page = Feel.all(page: current_page, page_size: 24)

    render(conn, "home.html",
      page: page,
      feels: group_by_tweet(page.entries)
    )
  end

  defp group_by_tweet(feels) do
    feels
    |> Enum.group_by(&(&1.tweet))
    |> Enum.into([])
  end
end
