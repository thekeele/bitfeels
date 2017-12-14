defmodule ExFeelsWeb.TweetsView do
  use ExFeelsWeb, :view

  def render("index.json", %{tweets: tweets}) do
    tweets
  end
end
