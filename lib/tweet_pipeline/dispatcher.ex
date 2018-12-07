defmodule Bitfeels.TweetPipeline.Dispatcher do
  use GenStage

  require Logger

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:consumer, opts, subscribe_to: [{Bitfeels.TweetPipeline.Sentiment, opts}]}
  end

  def handle_events(tweets, _from, opts) do
    sink = opts[:sink_to]

    for {tweet_id, tweet} <- tweets do
      Logger.info("""
      bitfeels tweet analysis
        sentiment: #{tweet["sentiment"]}
        score: #{tweet["score"]}

        tweet_id: #{tweet_id}
        text: #{tweet["text"]}
      """)
      :timer.sleep(3_000)

      case Process.whereis(sink) do
        nil -> :ok
        sink -> Process.send(sink, {:ok, {tweet_id, tweet}}, [:noconnect])
      end
    end

    {:noreply, [], opts}
  end
end
