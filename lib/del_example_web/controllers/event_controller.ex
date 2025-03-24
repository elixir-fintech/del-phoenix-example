defmodule DelExampleWeb.EventController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Event

  def index(conn, %{"instance_id" => instance_id}) do
    events = list_events(instance_id)
    render(conn, :index, events: events, instance_id: instance_id)
  end
end
