defmodule ExFeelsWeb.TwitterApi.Stream do

  alias ExFeelsWeb.TwitterApi.Auth

  @base_url "https://stream.twitter.com/1.1"

  def start() do
    # decoder = fn data -> :jsx.decode(data, [:stream]) end

    fetch_connection(nil, "")
  end

  defp fetch_connection(ref, tweet_data) do
    method = "GET"
    endpoint = "/statuses/filter.json"
    params = %{"track" => "twitter"}

    url = @base_url <> endpoint

    headers = ["Authorization": Auth.oauth_header(method, url, params)]

    opts = [recv_timeout: 500, stream_to: self()]

    url = maybe_query_params(url, params)

    {:ok, %HTTPoison.AsyncResponse{id: ref}} = HTTPoison.get(url, headers, opts)

    receive do
      %HTTPoison.AsyncStatus{code: 200, id: ref} ->
        IO.puts "status 200"
        fetch_connection(ref, tweet_data)

      %HTTPoison.AsyncHeaders{headers: headers, id: ref} ->
        IO.inspect headers, label: "headers"
        fetch_connection(ref, tweet_data)

      %HTTPoison.Error{reason: reason} ->
        IO.inspect reason, label: "error reason"
        {:error, reason}

      %HTTPoison.AsyncEnd{id: ^ref} ->
        IO.puts "done"
        {:done, tweet_data}

      %HTTPoison.AsyncChunk{chunk: chunk, id: ref} ->
        data = tweet_data <> chunk

        IO.puts "has chunk"

        fetch_connection(ref, data)

      other ->
        IO.inspect other, label: "httpoison other"
    end
  end

  # defp maybe_decode_chunk(decoder, tweet_data) do
  #   IO.inspect tweet_data, label: "tweet_data"

  #   IO.inspect decoder, label: "chunk decoder"
  #   case decoder.(tweet_data) do
  #     {:incomplete, fun} -> fun

  #     other -> IO.inspect other, label: "jsx other"
  #   end
  # end

  defp maybe_query_params(url, params) when map_size(params) == 0, do: url
  defp maybe_query_params(url, params), do: url <> "?#{URI.encode_query(params)}"
end
