defmodule Bitfeels.TweetSource do
  use GenStage

  def start_link(counter) do
    GenStage.start_link(__MODULE__, counter, name: __MODULE__)
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, counter) when demand > 0 do
    tweets =
      for _ <- counter..counter+demand-1 do
        :timer.sleep(3_000)

        TwitterStream.take_tweet()
      end

    tweets = List.flatten(tweets)

    {:noreply, tweets, counter + demand}
  end
end
