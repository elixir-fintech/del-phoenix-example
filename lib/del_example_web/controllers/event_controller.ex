defmodule DelExampleWeb.EventController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Event
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]

  def index(conn, %{"instance_id" => instance_id}) do
    instance = get_instance!(instance_id)
    events = list_events(instance.id)
    render(conn, :index, events: events, instance: instance)
  end

  def show(conn, %{"id" => id}) do
    %{processed_transaction_id: trx_id} = event = get_event(id)
    events = case trx_id do
      nil -> []
      _ -> Enum.filter(list_events_for_transaction(trx_id), fn e -> e.id != id end)
    end
    render(conn, :show, event: event, events: events)
  end
end
