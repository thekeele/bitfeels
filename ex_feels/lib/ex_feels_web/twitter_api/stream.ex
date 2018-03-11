defmodule ExFeelsWeb.TwitterApi.Stream do

  alias ExFeelsWeb.TwitterApi.Auth

  @base_url "https://stream.twitter.com/1.1"

  def start(params \\ %{"track" => "twitter"}) do
    case fetch_connection(params) do
      {:ok, ref} ->
        stream_body(ref, [])

      err -> err
    end
  end

  defp stream_body(ref, buffer) when length(buffer) < 3 do
    case :hackney.stream_body(ref) do
      {:ok, chunk} ->
        IO.puts "found chunk"

        buffer = [chunk | buffer]
        stream_body(ref, buffer)

      :done ->
        {:done, buffer}

      {:error, reason} ->
        IO.inspect reason, label: "error reason"
    end
  end
  defp stream_body(_, buffer), do: {:done, "#{length(buffer)} chunks from stream"}

  defp fetch_connection(params) do
    method = "GET"
    endpoint = "/statuses/filter.json"
    url = @base_url <> endpoint

    headers = [{"Authorization", Auth.oauth_header(method, url, params)}]

    opts = [{:recv_timeout, 60000}]

    url = maybe_query_params(url, params)

    case :hackney.request(method, url, headers, [], opts) do
      {:ok, 200, headers, ref} ->
        IO.inspect headers, label: "headers"
        {:ok, ref}

      error -> error
    end
  end

  defp maybe_query_params(url, params) when map_size(params) == 0, do: url
  defp maybe_query_params(url, params), do: url <> "?#{URI.encode_query(params)}"
end
