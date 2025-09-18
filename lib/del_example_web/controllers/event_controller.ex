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
    event = get_event(id)

    trx_events =
      case event.transactions do
        [] ->
          []

        [trx | _] ->
          Enum.filter(list_events_for_transaction(trx.id), fn e -> e.id != id end)
      end

    account_event =
      case event.account do
        nil ->
          []

        account ->
          Enum.filter(list_events_for_account(account.id), fn e -> e.id != id end)
      end

    render(conn, :show, event: event, events: trx_events ++ account_event)
  end
end
