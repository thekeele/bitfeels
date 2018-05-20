defmodule Twitter.Stream do
  use GenServer

  alias Twitter.OAuth, as: Auth

  @stream_api "https://stream.twitter.com/1.1"

  ## Client

  def start_link(),
    do: GenServer.start_link(__MODULE__, %{tweets: []}, name: __MODULE__)

  def start_streaming(opts),
    do: GenServer.call(__MODULE__, {:start_streaming, opts})

  def stop_streaming(),
    do: GenServer.call(__MODULE__, :stop_streaming)

  def get_tweets(),
    do: GenServer.call(__MODULE__, :get_tweets)

  def get_latest_tweet(),
    do: GenServer.call(__MODULE__, :get_latest_tweet)

  ## Server

  def init(stream_state), do: {:ok, stream_state}

  def handle_call({:start_streaming, stream_opts}, _from, stream_state) do
    {:ok, ref} = get_async_stream(stream_opts)

    {:reply, :ok, stream_state |> Map.put(:ref, ref) |> Map.put(:opts, stream_opts)}
  end

  def handle_call(:stop_streaming, _from, stream_state) do
    {:ok, ref} = :hackney.stop_async(stream_state[:ref])

    resp = if is_reference(ref), do: :hackney.close(ref), else: :ok

    {:reply, resp, %{tweets: stream_state.tweets}}
  end

  def handle_call(:get_tweets, _from, stream_state),
    do: {:reply, stream_state.tweets, stream_state}

  def handle_call(:get_latest_tweet, _from, stream_state) do
    latest_tweet = List.first(stream_state.tweets)

    current_state = %{
      latest_tweet: latest_tweet,
      stream: %{ref: stream_state[:ref], decoder: stream_state[:decoder], opts: stream_state[:opts]}
    }

    {:reply, current_state, stream_state}
  end

  def handle_info({:hackney_response, ref, {:status, 200, "OK"}}, stream_state) do
    :ok = :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  def handle_info({:hackney_response, ref, {:headers, _headers}}, stream_state) do
    :ok = :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  def handle_info({:hackney_response, _ref, :done}, stream_state) do
    {:ok, ref} = get_async_stream(stream_state.opts)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  def handle_info({:hackney_response, ref, ""}, stream_state) do
    :ok = :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  def handle_info({:hackney_response, ref, chunk}, stream_state) when is_binary(chunk) do
    stream_state =
      chunk
      |> try_apply_decoder(stream_state)
      |> put_decoded_stream_state(stream_state)

    :ok = :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  ## Private

  defp get_async_stream(stream_opts) do
    url = @stream_api <> "/statuses/filter.json"
    params = stream_opts[:query_params]
    headers = ["Authorization": Auth.oauth_header(:get, url, params)]

    :hackney.get(
      "#{url}?#{URI.encode_query(params)}",
      headers,
      "",
      [{:async, :once}, {:stream_to, __MODULE__}]
    )
  end

  defp try_apply_decoder(chunk, %{decoder: decoder}) do
    try do
      decoder.(:end_stream)
    rescue
      _error in ArgumentError ->
        decoder.(chunk)
    end
  end

  defp try_apply_decoder(chunk, _stream_state) do
    try do
      :jsx.decode(chunk, [:stream, :return_maps])
    rescue
      _error in ArgumentError ->
        :ok
    end
  end

  defp put_decoded_stream_state({:incomplete, decoder}, stream_state),
    do: Map.put(stream_state, :decoder, decoder)

  defp put_decoded_stream_state(:ok, stream_state), do: stream_state

  defp put_decoded_stream_state(json, stream_state) do
    tweets = [json | stream_state.tweets]

    Process.sleep(stream_state.opts[:chunk_rate])

    stream_state
    |> Map.put(:tweets, tweets)
    |> Map.delete(:decoder)
  end
end
