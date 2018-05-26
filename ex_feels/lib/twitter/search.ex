defmodule Twitter.Search do
  use Timex

  alias Twitter.OAuth, as: Auth

  @rest_api "https://api.twitter.com/1.1"

  def search(%{params: params, window: window}) do
    query = URI.encode("#{params["q"]} since:#{last(window)}")
    params = Map.put(params, "q", query)

    url = @rest_api <> "/search/tweets.json"
    headers = [{"Authorization", Auth.oauth_header(:get, url, params)}]

    response =
      :hackney.get(
        url <> "?#{URI.encode_query(params)}",
        headers,
        "",
        [:with_body]
      )

    with {:ok, 200, _headers, resp_body} <- response,
         {:ok, %{"statuses" => statuses}} <- Poison.decode(resp_body) do
      statuses
    else
      {:ok, status, _headers, resp_body} when status > 200 ->
        {:error, Poison.decode!(resp_body)}

      [] ->
        []

      error ->
        {:error, "#{inspect error}"}
    end
  end

  defp last(search_window) do
    %{year: year, month: month, day: day} = Timex.now |> Timex.shift(search_window)

    "#{year}-#{month}-#{day}"
  end
end
