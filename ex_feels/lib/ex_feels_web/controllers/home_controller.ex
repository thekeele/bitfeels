defmodule ExFeelsWeb.HomeController do
  use ExFeelsWeb, :controller

  alias ExFeels.Feel

  def home(conn, _params) do
    feels = Feel.all()

    render(conn, "home.html", feels: feels)
  end
end
