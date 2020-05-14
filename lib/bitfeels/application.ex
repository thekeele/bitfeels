defmodule Bitfeels.Application do
  use Application

  def start(_type, _args) do
    stream_opts = Application.get_env(:bitfeels, :twitter_stream)
    tweet_sink = stream_opts[:tweet_sink] || self()

    children = [
      {Registry, keys: :unique, name: Registry.Streams},
      {Bitfeels.Pipeline.Source, []},
      {Bitfeels.Pipeline.Dispatcher, []},
      {Bitfeels.Pipeline.Sentiment, [sink: tweet_sink]},
      {Bitfeels.StreamSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Bitfeels.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

