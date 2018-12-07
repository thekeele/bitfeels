defmodule Bitfeels.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    twitter_stream = Application.get_env(:bitfeels, :twitter_stream)
    tweet_pipeline = Application.get_env(:bitfeels, :tweet_pipeline)

    children = [
      worker(TwitterStream.RealtimeTweets, [%{
        "track" => twitter_stream[:track] || "bitcoin",
        "language" => twitter_stream[:language] || "en",
        "filter_level" => twitter_stream[:filter_level] || "none"
      }]),
      worker(Bitfeels.TweetSource, [[
        counter: 0,
        source: TwitterStream,
        fun: :take_tweet
      ]]),
      supervisor(Bitfeels.TweetPipeline, [[
        max_demand: 10,
        min_demand: 3,
        sink_to: tweet_pipeline[:sink] || :bitfeels_sink
      ]]),
    ]

    opts = [strategy: :one_for_one, name: Bitfeels.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

