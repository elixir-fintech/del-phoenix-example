defmodule DelExampleWeb.EventController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Event
  import DelExample.DoubleEntryLedgerWeb.Account, only: [get_accounts_for_dropdown: 1]

  def new(conn, %{"instance_id" => instance_id}) do
    render(conn, :new, changeset: event_map_changeset(), instance_id: instance_id, accounts: get_accounts_for_dropdown(instance_id))
  end

  def create(conn, %{"event_map" => event_params, "instance_id" => instance_id}) do
    event_params = Map.put(event_params, "instance_id", instance_id)

    case create_event(event_params) do
      {:ok, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect(to: ~p"/instances/#{instance_id}")

      {:error, message, changeset} ->
        put_flash(conn, :error, message)
        |> render(:new, changeset: changeset, instance_id: instance_id, accounts: get_accounts_for_dropdown(instance_id))
    end
  end

  def index(conn, %{"instance_id" => instance_id}) do
    events = list_events(instance_id)
    render(conn, :index, events: events, instance_id: instance_id)
  end
end
