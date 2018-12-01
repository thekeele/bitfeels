defmodule Bitfeels.TweetSource do
  use GenStage

  def start_link(counter \\ 0) do
    GenStage.start_link(__MODULE__, counter, name: __MODULE__)
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, counter) when demand > 0 do
    tweets =
      for _ <- counter..counter+demand-1 do
        # wait for demand
        :timer.sleep(3_000)
        IO.puts "taking tweet...."
        TwitterStream.take_tweet()
      end

    tweets = List.flatten(tweets)

    {:noreply, tweets, counter + demand}
  end
end
