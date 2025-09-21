defmodule DelExampleWeb.EventController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Event
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]

  def index(conn, %{"instance_id" => instance_id}) do
    instance = get_instance!(instance_id)
    events = list_events(instance.id)
    render(conn, :index, events: events, instance: instance)
  end

  def show(conn, %{"instance_id" => instance_id, "id" => id}) do
    event = get_event(id)
    instance = get_instance!(instance_id)

    render(conn, :show, event: event, events: get_related_events(event), instance: instance)
  end
end
