defmodule Bitfeels.Application do
  use Application

  def start(_type, _args) do
    sink = Application.get_env(:bitfeels, :twitter_stream)[:sink] || self()
    events = [
      [:bitfeels, :pipeline, :source],
      [:bitfeels, :pipeline, :sentiment]
    ]

    children = [
      {Registry, keys: :unique, name: Registry.Streams},
      {Bitfeels.Pipeline.Source, []},
      {Bitfeels.Pipeline.Dispatcher, []},
      {Bitfeels.Pipeline.Sentiment, [sink: sink]},
      {Bitfeels.StreamSupervisor, []},
      {Bitfeels.Reporter, [events: events]}
    ]

    opts = [strategy: :one_for_one, name: Bitfeels.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

