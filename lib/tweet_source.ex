defmodule Bitfeels.TweetSource do
  use GenStage

  require Logger

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:producer, {opts[:counter], opts}}
  end

  def handle_demand(demand, {counter, opts}) when demand > 0 do
    tweets =
      for tweets <- counter..(counter + demand - 1) do
        Logger.info("""
        twitter stream found tweet
          total_streamed: #{tweets + 1}
        """)
        # wait for demand to build
        :timer.sleep(3_000)

        apply(opts[:source], opts[:fun], [])
      end

    tweets = List.flatten(tweets)

    {:noreply, tweets, {counter + demand, opts}}
  end
end
