defmodule ExFeelsWeb.Twitter.HTTP do

  alias ExFeelsWeb.Twitter.Crypto

  @base_url "https://api.twitter.com/1.1"

  def request(method, endpoint, params \\ %{}) do
    url = @base_url <> endpoint

    headers = [{"Authorization", Crypto.oauth_header(method, url, params)}]

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
