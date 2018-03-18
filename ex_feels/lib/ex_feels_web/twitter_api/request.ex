defmodule ExFeelsWeb.TwitterApi.Request do

  alias ExFeelsWeb.TwitterApi.Auth

  @base_url "https://api.twitter.com/1.1"

  def get(endpoint, params \\ %{}) do
    method = "GET"
    url = @base_url <> endpoint

    headers = [{"Authorization", Auth.oauth_header(method, url, params)}]

    url = maybe_query_params(url, params)

    case :hackney.request(method, url, headers, [], [:with_body]) do
      {:ok, 200, _headers, body} ->
        Poison.decode(body)

      {:ok, status, _headers, body} when status > 200 ->
        {:ok, resp} = Poison.decode(body)

        {:error, resp}

      {:error, error} ->
        {:error, "#{inspect error}"}
    end
  end

  defp maybe_query_params(url, params) when map_size(params) == 0, do: url
  defp maybe_query_params(url, params), do: url <> "?#{URI.encode_query(params)}"
end
