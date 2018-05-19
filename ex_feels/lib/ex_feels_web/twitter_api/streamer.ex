defmodule ExFeelsWeb.TwitterApi.Streamer do
  use GenServer

  alias ExFeelsWeb.TwitterApi

  ## Client

  def start_link(), do:
    GenServer.start_link(__MODULE__, %{tweets: []}, name: __MODULE__)

  def start_streaming(opts \\ [chunk_time: 5_000]), do:
    GenServer.call(__MODULE__, {:start_streaming, opts})

  def stop_streaming(), do:
    GenServer.call(__MODULE__, :stop_streaming)

  def get_stream(), do:
    GenServer.call(__MODULE__, :get_stream)

  ## Server

  def init(stream_state), do:
    {:ok, stream_state}

  def handle_call({:start_streaming, opts}, _from, stream_state) do
    {:ok, ref} = TwitterApi.stream_statuses(to: __MODULE__)

    {:reply, :ok, stream_state |> Map.put(:ref, ref) |> Map.put(:opts, opts)}
  end

  def handle_call(:stop_streaming, _from, stream_state) do
    {:ok, ref} = :hackney.stop_async(stream_state.ref)
    :hackney.close(ref)

    {:reply, :ok, stream_state |> Map.delete(:ref) |> Map.delete(:decoder)}
  end

  def handle_call(:get_stream, _from, stream_state), do:
    {:reply, stream_state, stream_state}

  def handle_info({:hackney_response, ref, {:status, 200, "OK"}}, stream_state) do
    :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  def handle_info({:hackney_response, ref, {:headers, _headers}}, stream_state) do
    :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  def handle_info({:hackney_response, ref, chunk}, stream_state) when is_binary(chunk) do
    stream_state =
      chunk
      |> apply_decoder(stream_state)
      |> put_decoded_stream_state(stream_state)

    Process.sleep(stream_state.opts[:chunk_time])

    :hackney.stream_next(ref)

    {:noreply, Map.put(stream_state, :ref, ref)}
  end

  ## Private

  defp apply_decoder(chunk, %{decoder: decoder}) do
    try do
      decoder.(:end_stream)
    rescue
      _error in ArgumentError ->
        decoder.(chunk)
    end
  end

  defp apply_decoder(chunk, _stream_state) do
    try do
      :jsx.decode(chunk, [:stream])
    rescue
      _error in ArgumentError ->
        :ok
    end
  end

  defp put_decoded_stream_state({:incomplete, decoder}, stream_state), do:
    Map.put(stream_state, :decoder, decoder)

  defp put_decoded_stream_state(:ok, stream_state),
    do: stream_state

  defp put_decoded_stream_state(json, stream_state) do
    json = Enum.into(json, %{})
    tweets = [json["text"] | stream_state.tweets]

    stream_state
    |> Map.put(:tweets, tweets)
    |> Map.delete(:decoder)
  end
end
