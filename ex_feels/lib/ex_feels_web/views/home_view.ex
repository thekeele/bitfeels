defmodule ExFeelsWeb.HomeView do
  use ExFeelsWeb, :view

  def sentiment(sentiment) when is_binary(sentiment),
    do: sentiment|> String.to_integer()|> sentiment()
  def sentiment(sentiment) when is_integer(sentiment) do
    cond do
      sentiment == -1 -> {"danger", "😭"}
      sentiment == 0 -> {"light", "😐"}
      sentiment == 1 -> {"success", "🤑"}
    end
  end
end
