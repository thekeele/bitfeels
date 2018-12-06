defmodule Bitfeels.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    twitter_stream = Application.get_env(:bitfeels, :twitter_stream, %{"track" => "bitcoin"})

    children = [
      worker(TwitterStream.RealtimeTweets, [twitter_stream]),
      worker(Bitfeels.TweetSource, []),
      supervisor(Bitfeels.TweetPipeline, [[max_demand: 10, min_demand: 3]]),
    ]

    opts = [strategy: :one_for_one, name: Bitfeels.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

