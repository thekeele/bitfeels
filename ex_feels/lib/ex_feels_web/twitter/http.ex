defmodule ExFeelsWeb.Twitter.HTTP do
  alias ExFeelsWeb.Twitter.Crypto

  @base_url "https://api.twitter.com/1.1"

  def request(method, endpoint) do
    url = @base_url <> endpoint
    headers = [{"Authorization", Crypto.oauth_header(method, url)}]

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
end
