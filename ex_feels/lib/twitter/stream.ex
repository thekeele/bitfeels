defmodule Twitter.Stream do
  use GenServer

  require Logger

  alias Twitter.OAuth, as: Auth

  @stream_api "https://stream.twitter.com/1.1"

  ## Client side API

  def start_link(),
    do: GenServer.start_link(__MODULE__, %{tweets: [], stream: %{}}, name: __MODULE__)

  def start_streaming(opts),
    do: GenServer.call(__MODULE__, {:start_streaming, opts})

  def stop_streaming(),
    do: GenServer.call(__MODULE__, :stop_streaming)

  def get_tweets(),
    do: GenServer.call(__MODULE__, :get_tweets)

  def get_latest_tweet(),
    do: GenServer.call(__MODULE__, :get_latest_tweet)

  def take_tweets_from_stream(amount),
    do: GenServer.call(__MODULE__, {:take_tweets_from_stream, amount})

  def get_stream_status(),
    do: GenServer.call(__MODULE__, :get_stream_status)

## Server side handlers

  def init(stream_state), do: {:ok, stream_state |> log(":init")}

  def handle_call({:start_streaming, stream_opts}, _from, stream_state) do
    {:ok, ref} = get_async_stream(stream_opts) |> log(":start_streaming")

    {:reply, :ok, put_in(stream_state, [:stream], %{ref: ref, opts: stream_opts})}
  end

  def handle_call(:stop_streaming, _from, stream_state) do
    {:ok, ref} = :hackney.stop_async(stream_state.stream[:ref]) |> log(":stop_streaming")

    resp = if is_reference(ref), do: :hackney.close(ref), else: :ok

    {:reply, resp, %{tweets: stream_state.tweets, stream: %{}}}
  end

  def handle_call(:get_tweets, _from, stream_state),
    do: {:reply, stream_state.tweets, stream_state}

  def handle_call(:get_latest_tweet, _from, stream_state) do
    latest_tweet = List.first(stream_state.tweets) || %{}

    {:reply, latest_tweet, stream_state}
  end

  def handle_call({:take_tweets_from_stream, amount}, _from, stream_state) do
    taken_tweets = Enum.take(stream_state.tweets, amount)

    stream_tweets =
      stream_state.tweets
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(taken_tweets))
      |> MapSet.to_list()

    {:reply, taken_tweets, %{tweets: stream_tweets, stream: stream_state.stream}}
  end

  def handle_call(:get_stream_status, _from, stream_state) do
    {:reply, stream_state.stream, stream_state}
  end

  ## Server stream handlers

  def handle_info({:hackney_response, ref, {:status, 200, "OK"}}, stream_state) do
    :ok = :hackney.stream_next(ref) |> log(":status")

    {:noreply, put_in(stream_state, [:stream, :ref], ref)}
  end

  def handle_info({:hackney_response, ref, {:headers, _headers}}, stream_state) do
    :ok = :hackney.stream_next(ref) |> log(":headers")

    {:noreply, put_in(stream_state, [:stream, :ref], ref)}
  end

  def handle_info({:hackney_response, _ref, :done}, stream_state) do
    {:ok, ref} = get_async_stream(stream_state.stream.opts) |> log(":done")

    {:noreply, put_in(stream_state, [:stream, :ref], ref)}
  end

  def handle_info({:hackney_response, ref, ""}, stream_state) do
    :ok = :hackney.stream_next(ref) |> log(":empty")

    {:noreply, put_in(stream_state, [:stream, :ref], ref)}
  end

  def handle_info({:hackney_response, ref, chunk}, stream_state) when is_binary(chunk) do
    log(:ok, ":chunk")

    stream_state =
      chunk
      |> try_apply_decoder(stream_state.stream)
      |> put_decoded_stream_state(stream_state)

    Process.sleep(stream_state.stream.opts[:chunk_rate])

    stream_state =
      case :hackney.stream_next(ref) do
        :ok ->
          put_in(stream_state, [:stream, :ref], ref)

        {:error, :req_not_found}
          stream_state
      end

    {:noreply, stream_state}
  end

  ## Private

  defp get_async_stream(stream_opts) do
    url = @stream_api <> "/statuses/filter.json"
    params = stream_opts[:query_params]
    headers = ["Authorization": Auth.oauth_header(:get, url, params)]

    :hackney.get(
      url <> "?#{URI.encode_query(params)}",
      headers,
      "",
      [{:async, :once}, {:stream_to, __MODULE__}]
    )
  end

  defp try_apply_decoder(chunk, %{decoder: decoder}) do
    try do
      log(:ok, ":end_stream")
      decoder.(:end_stream)
    rescue
      _error in ArgumentError ->
        decoder.(chunk)
    end
  end

  defp try_apply_decoder(chunk, _stream_state) do
    try do
      :jsx.decode(chunk, [:stream, :return_maps]) |> log(":jsx.decode")
    rescue
      _error in ArgumentError ->
        log(:bad_chunk, ":jsx.decode")
        :bad_chunk
    end
  end

  defp put_decoded_stream_state({:incomplete, decoder}, stream_state),
    do: put_in(stream_state, [:stream, :decoder], decoder)

  defp put_decoded_stream_state(:bad_chunk, stream_state), do: stream_state

  defp put_decoded_stream_state(json, stream_state) do
    tweet = ExFeels.Twitter.Tweet.parse_to_tweets(json) |> log(":tweet")

    tweets = [tweet | stream_state.tweets]

    %{tweets: tweets, stream: Map.delete(stream_state.stream, :decoder)}
  end

  defp log(data, action) do
    Logger.info fn ->
      """
      [#{action}]
      #{inspect data}
      """
    end

    data
  end
end
