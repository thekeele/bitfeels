defmodule Bitfeels.Pipeline.Source do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, :ok}
  end

  def handle_info({:tweet, event}, :ok) do
    :ok = Bitfeels.Pipeline.Dispatcher.notify(event)
    {:noreply, :ok}
  end
end
