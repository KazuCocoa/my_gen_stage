alias Experimental.GenStage

# [A] -> [B] -> [C]
# [A] is producer
# [B] is producer_consumer
# [C] is consumer

defmodule A do
  use GenStage

  def init(counter), do: {:producer, counter}

  def handle_demand(demand, counter) when demand > 0 do
    events = Enum.to_list counter..(counter + demand - 1)
    {:noreply, events, counter + demand}
  end
end

defmodule B do
  use GenStage

  def init(number), do: {:producer_consumer, number}

  def handle_events(events, _from, number) do
    events = Enum.map events, &(&1 * number)
    {:noreply, events, number}
  end
end

defmodule C do
  use GenStage

  def init(sleeping_time), do: {:consumer, sleeping_time}

  def handle_events(events, _from, sleeping_time) do
    IO.inspect events
    Process.sleep(sleeping_time)

    {:noreply, [], sleeping_time}
  end
end

defmodule MyGenStageExample do
  def run1 do
    {:ok, a} = GenStage.start_link A, 0
    {:ok, b} = GenStage.start_link B, 2
    {:ok, c} = GenStage.start_link C, 1_000 # sleep for a second

    GenStage.sync_subscribe c, to: b
    GenStage.sync_subscribe b, to: a

    Process.sleep :infinity
  end

  def run2 do
    {:ok, a} = GenStage.start_link A, 0      # starting from zero
    {:ok, b} = GenStage.start_link B, 2      # multiply by 2

    {:ok, c1} = GenStage.start_link C, 1_000 # sleep for a second
    {:ok, c2} = GenStage.start_link C, 1_000 # sleep for a second
    {:ok, c3} = GenStage.start_link C, 1_000 # sleep for a second
    {:ok, c4} = GenStage.start_link C, 1_000 # sleep for a second

    GenStage.sync_subscribe c1, to: b
    GenStage.sync_subscribe c2, to: b
    GenStage.sync_subscribe c3, to: b
    GenStage.sync_subscribe c4, to: b
    GenStage.sync_subscribe b, to: a

    Process.sleep :infinity
  end
end
