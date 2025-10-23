defmodule DelExampleWeb.JournalEventController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.JournalEvent
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]

  def index(conn, %{"instance_address" => instance_address}) do
    instance = get_instance!(instance_address)
    events = list_events(instance.id)
    render(conn, :index, events: events, instance: instance)
  end

  def show(conn, %{"instance_address" => instance_address, "id" => id}) do
    event = get_event(instance_address, id)

    #render(conn, :show, event: event, events: get_related_events(event), instance: event.instance)
    render(conn, :show, event: event, events: [], instance: event.instance)
  end
end
