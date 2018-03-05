defmodule ExFeelsWeb.FeelView do
  use ExFeelsWeb, :view

  import Scrivener.HTML

  def sentiment(sentiment) when is_binary(sentiment),
    do: sentiment|> String.to_integer()|> sentiment()
  def sentiment(sentiment) when is_integer(sentiment) do
    cond do
      sentiment == -1 -> {"danger", "😭"}
      sentiment == 0 -> {"light", "😐"}
      sentiment == 1 -> {"success", "🤑"}
    end
  end

  def left_arrow(), do: Phoenix.HTML.raw("&leftarrow;")
  def right_arrow(), do: Phoenix.HTML.raw("&rightarrow;")
end
