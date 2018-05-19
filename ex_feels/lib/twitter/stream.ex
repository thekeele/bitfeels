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

  ## Server

  def init(stream_state),
    do: {:ok, stream_state}

  def handle_call({:start_streaming, stream_opts}, _from, stream_state) do
    url = @stream_api <> "/statuses/filter.json"
    params = %{"track" => "twitter"}
    headers = ["Authorization": Auth.oauth_header(:get, url, params)]

    {:ok, ref} =
      :hackney.get(
        "#{url}?#{URI.encode_query(params)}",
        headers,
        "",
        [{:async, :once}, {:stream_to, __MODULE__}]
      )

    {:reply, :ok, stream_state |> Map.put(:ref, ref) |> Map.put(:opts, stream_opts)}
  end

  def handle_call(:stop_streaming, _from, stream_state) do
    {:ok, ref} = :hackney.stop_async(stream_state.ref)
    :hackney.close(ref)

    {:reply, :ok, stream_state |> Map.delete(:ref) |> Map.delete(:decoder)}
  end

  def handle_call(:get_tweets, _from, stream_state),
    do: {:reply, stream_state.tweets, stream_state}

  def handle_info({:hackney_response, ref, {:status, 200, "OK"}}, stream_state) do
    :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  def handle_info({:hackney_response, ref, {:headers, _headers}}, stream_state) do
    :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  def handle_info({:hackney_response, _ref, :done}, stream_state),
    do: {:noreply, stream_state}

  def handle_info({:hackney_response, ref, chunk}, stream_state) when is_binary(chunk) do
    stream_state =
      chunk
      |> try_apply_decoder(stream_state)
      |> put_decoded_stream_state(stream_state)

    :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  ## Private

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
      :jsx.decode(chunk, [:stream])
    rescue
      _error in ArgumentError ->
        :ok
    end
  end

  defp put_decoded_stream_state({:incomplete, decoder}, stream_state),
    do: Map.put(stream_state, :decoder, decoder)

  defp put_decoded_stream_state(:ok, stream_state),
    do: stream_state

  defp put_decoded_stream_state(json, stream_state) do
    tweet = Enum.into(json, %{})
    tweets = [tweet | stream_state.tweets]

    Process.sleep(stream_state.opts[:chunk_rate])

    stream_state
    |> Map.put(:tweets, tweets)
    |> Map.delete(:decoder)
  end
end
