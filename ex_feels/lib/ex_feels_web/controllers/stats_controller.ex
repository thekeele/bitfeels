defmodule ExFeelsWeb.StatsController do
  use ExFeelsWeb, :controller

  alias ExFeels.Stat

  def index(conn, _params) do
    stats = Stat.all()

    render(conn, "index.json", stats: stats)
  end
end
