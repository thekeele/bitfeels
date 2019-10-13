defmodule Bitfeels.StreamSupervisor do
  use DynamicSupervisor

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_child(user, track, filter_level) do
    params = %{"track" => track, "language" => "en", "filter_level" => filter_level}
    name = {:via, Registry, {Registry.Streams, "#{user}_#{track}"}}
    spec = {TwitterStream, name: name, params: params, sink: Bitfeels.Pipeline.Source}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one, max_children: 2)
  end
end
