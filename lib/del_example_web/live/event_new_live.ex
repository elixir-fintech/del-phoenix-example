defmodule DelExampleWeb.EventNewLive do
      alias DoubleEntryLedger.Event.EventMap
  use DelExampleWeb, :live_view

  import DelExample.DoubleEntryLedgerWeb.Event
  import DelExample.DoubleEntryLedgerWeb.Account, only: [get_accounts_for_dropdown: 1]
  alias DoubleEntryLedger.Event.EntryData
  alias DoubleEntryLedger.Event.TransactionData
  alias DoubleEntryLedger.Event.EventMap

  @impl true
  def mount(%{"instance_id" => instance_id}, _session, socket) do
    changeset = EventMap.changeset(
      %EventMap{
        action: :create,
        instance_id: instance_id,
        transaction_data: %TransactionData{status: :posted, entries: []}},
        %{}
      )
    {:ok, assign(socket, instance_id: instance_id, accounts: get_accounts_for_dropdown(instance_id), changeset: changeset)}
  end

  @impl true
  def handle_event("add-entry", _params, socket) do
    stored_changeset = socket.assigns.changeset
    transaction_data = Ecto.Changeset.get_field(stored_changeset, :transaction_data)

    entries = transaction_data.entries ++ [%EntryData{currency: :EUR}]

    changeset =
      stored_changeset
      |> Ecto.Changeset.change(%{transaction_data: %{transaction_data | entries: entries}})

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("validate", %{"event_map" => params}, socket) do
    changeset =
      socket.assigns.changeset
      |> EventMap.changeset(params)
    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"event_map" => params}, socket) do
    params = Map.put(params, "instance_id", socket.assigns.instance_id)
    case create_event(params) do
      {:ok, message} ->
        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/instances/#{socket.assigns.instance_id}")}

      {:error, message, changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, message)}
    end
  end
end
