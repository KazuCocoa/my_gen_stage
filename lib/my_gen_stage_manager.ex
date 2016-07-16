alias Experimental.GenStage

defmodule MyGenStageManager do
  use GenStage

  def start_link(), do: GenStage.start_link __MODULE__, :ok, name: __MODULE__

  def sync_notify(event, timeout \\ 5000) do
    GenStage.call __MODULE__, {:notify, event}, timeout
  end

  ## Callbacks
  def init(:ok) do
    {:producer, {:queue.new, 0}, dispacher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:notify, event}, from, {queue, demand}) do
    dispatch_events(:queue.in({from, event}, queue), demand, [])
  end

  def handle_demand(incoming_demand, {queue, demand}) do
    dispatch_events(queue, incoming_demand + demand, [])
  end

  defp dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand,
         {item, queue} = :queue.out(queue),
         {:value, {from, event}} <- item do
      GenStage.reply from, :ok
      dispatch_events queue, demand - 1, [event | events]
    end
  else
    _ -> {:noreply, Enum.reverse(events), {queue, demand}}
  end
end


defmodule MyGenStageEventHandler do
  use GenStage

  def start_link(), do: GenStage.start_link(__MODULE__, :ok)

  # Callbacks

  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [MyGenStageEventHandler]}
  end

  def handle_events(events, _from, state) do
    IO.inspect events
    {:noreply, [], state}
  end
end
