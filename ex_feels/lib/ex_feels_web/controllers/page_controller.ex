defmodule ExFeelsWeb.PageController do
  use ExFeelsWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
