defmodule Bitfeels.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    arg = Application.get_env(:bitfeels, :twitter_stream)

    children = [
      worker(TwitterStream.RealtimeTweets, [arg])
    ]

    opts = [strategy: :one_for_one, name: Bitfeels.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
