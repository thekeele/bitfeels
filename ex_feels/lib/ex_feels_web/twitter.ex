defmodule ExFeelsWeb.Twitter do

  alias ExFeelsWeb.Twitter.HTTP

  def account_settings() do
    case HTTP.request("GET", "/account/settings.json") do
      {:ok, resp} ->
        Map.take(resp, ["language", "screen_name", "time_zone"])

      error -> error
    end
  end
end
