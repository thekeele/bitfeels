defmodule Bitfeels.TweetSource do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, :ok}
  end

  def handle_info({:tweet, event}, :ok) do
    :ok = Bitfeels.TweetDispatcher.notify(event)
    {:noreply, :ok}
  end
end
