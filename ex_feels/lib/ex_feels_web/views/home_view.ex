defmodule ExFeelsWeb.HomeView do
  use ExFeelsWeb, :view

  def binary_sentiment(sentiment) when is_binary(sentiment) do
    sentiment = String.to_integer(sentiment)

    cond do
      sentiment == -1 -> "😭"
      sentiment == 0 -> "😐"
      sentiment == 1 -> "🤑"
    end
  end
end
