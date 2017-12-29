defmodule ExFeelsWeb.HomeController do
  use ExFeelsWeb, :controller

  def home(conn, _params) do
    render conn, "home.html"
  end
end
