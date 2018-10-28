defmodule Bitfeels.TweetPipeline do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    children = [
      worker(__MODULE__.Parser, [opts]),
      worker(__MODULE__.Sentiment, [opts]),
      worker(__MODULE__.Datastore, [opts])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    supervise(children, opts)
  end
end
