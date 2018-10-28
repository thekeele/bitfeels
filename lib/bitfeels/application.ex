defmodule Bitfeels.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    opts = Application.get_env(:bitfeels, __MODULE__)

    children = [
      worker(TwitterStream.RealtimeTweets, [opts[:twitter_stream]]),
      worker(Bitfeels.TweetSource, [opts[:source_counter]]),
      supervisor(Bitfeels.TweetPipeline, [opts[:tweet_pipeline]]),
      # supervisor(Bitfeels.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: Bitfeels.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

