defmodule Bitfeels.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    twitter_stream = Application.get_env(:bitfeels, :twitter_stream)

    children = [
      worker(Bitfeels.TweetSource, []),
      worker(Bitfeels.TweetDispatcher, []),
      worker(Bitfeels.TweetFeels, [[
        sink: twitter_stream[:sink]
      ]]),
      worker(TwitterStream, [%{
        params: %{
          "track" => twitter_stream[:track],
          "language" => twitter_stream[:language],
          "filter_level" => twitter_stream[:filter_level]
          },
        source: Bitfeels.TweetSource
      }]),
    ]

    opts = [strategy: :one_for_one, name: Bitfeels.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

