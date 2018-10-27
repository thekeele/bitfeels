defmodule Bitfeels.Source do
  use GenStage

  def start_link(counter) do
    GenStage.start_link(__MODULE__, counter, name: __MODULE__)
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, counter) when demand > 0 do
    # simulate time to generate demand
    :timer.sleep(1_000)
    events = Enum.to_list(counter..counter+demand-1)

    {:noreply, events, counter + demand}
  end
end
