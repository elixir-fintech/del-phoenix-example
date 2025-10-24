defmodule DelExampleWeb.EventApiController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Event

  def show(conn, %{"instance_address" => instance_address, "id" => id}) do
    event = get_event(instance_address, id)
    render(conn, :show, event: event, related_events: get_related_events(event, :same_type))
  end

  def create(conn, event_params) do
    case create(event_params) do
      {:ok, event} ->
        conn
        |> put_status(:created)
        |> render(:created, event: event)

      {:error, _error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: DelExampleWeb.ErrorJSON)
        |> render(:"422")
    end
  end
end
