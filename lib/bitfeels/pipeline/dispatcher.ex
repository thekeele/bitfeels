defmodule Bitfeels.Pipeline.Dispatcher do
  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def notify(event, timeout \\ 1000) do
    GenStage.call(__MODULE__, {:notify, event}, timeout)
  end

  def init(_opts) do
    {:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:notify, event}, from, {queue, pending_demand}) do
    queue = :queue.in({from, event}, queue)
    dispatch_events(queue, pending_demand, [])
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, {from, event}}, queue} ->
        GenStage.reply(from, :ok)
        dispatch_events(queue, demand - 1, [event | events])
      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
