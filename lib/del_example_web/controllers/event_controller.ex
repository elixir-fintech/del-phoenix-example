defmodule DelExampleWeb.EventController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Event
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]

  def index(conn, %{"instance_address" => instance_address}) do
    instance = get_instance!(instance_address)
    events = list_events(instance.id)
    render(conn, :index, events: events, instance: instance)
  end

  def show(conn, %{"instance_address" => instance_address, "id" => id}) do
    event = get_event(id)
    instance = get_instance!(instance_address)

    render(conn, :show, event: event, events: get_related_events(event), instance: instance)
  end
end
