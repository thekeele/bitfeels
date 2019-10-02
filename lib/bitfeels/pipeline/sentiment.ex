defmodule Bitfeels.Pipeline.Sentiment do
  use GenStage

  alias Bitfeels.Tweet

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:consumer, opts, subscribe_to: [{Bitfeels.Pipeline.Dispatcher, opts}]}
  end

  def handle_events(statuses, _from, opts) do
    statuses
    |> Tweet.Parser.parse_to_tweet()
    |> Tweet.Sentiment.sentiment_analysis()
    |> Enum.map(&send_tweet_message(&1, opts))

    {:noreply, [], opts}
  end

  defp send_tweet_message(tweet, opts) do
    measurements = %{id: tweet["id"], score: tweet["score"]}
    metadata = %{time: System.os_time(:millisecond)}
    :telemetry.execute([:bitfeels, :pipeline, :sentiment], measurements, metadata)

    send(opts[:sink], {:tweet, {tweet["id"], tweet}})
  end
end
