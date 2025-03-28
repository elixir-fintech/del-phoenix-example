defmodule DelExampleWeb.EventNewLive do
      alias DoubleEntryLedger.Event.EventMap
  use DelExampleWeb, :live_view

  import DelExample.DoubleEntryLedgerWeb.Event
  import DelExample.DoubleEntryLedgerWeb.Account, only: [list_accounts: 1]
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]
  alias DoubleEntryLedger.Event.EntryData
  alias DoubleEntryLedger.Event.TransactionData
  alias DoubleEntryLedger.Event.EventMap

  @impl true
  def mount(%{"instance_id" => instance_id}, _session, socket) do
    instance = get_instance!(instance_id)
    changeset = EventMap.changeset(
      %EventMap{
        action: :create,
        instance_id: instance_id,
        transaction_data: %TransactionData{status: :posted, entries: []}},
        %{}
      )
    {:ok, accounts} = list_accounts(instance_id)
    options = %{
      accounts: Enum.map(accounts, fn acc -> ["#{acc.name}: #{acc.type} ": acc.id] end) |> List.flatten(),
      actions: DoubleEntryLedger.Event.actions(),
      states: DoubleEntryLedger.Transaction.states(),
      currencies: DoubleEntryLedger.Currency.currency_atoms
    }

    {:ok, assign(socket, instance: instance, accounts: accounts, options: options, changeset: changeset)}
  end

  @impl true
  def handle_event("add-entry", _params, socket) do
    stored_changeset = socket.assigns.changeset
    [account | _] = socket.assigns.accounts
    transaction_data = Ecto.Changeset.get_field(stored_changeset, :transaction_data)
    new_entry = %EntryData{account_id: account.id, currency: account.currency}
    entries = transaction_data.entries ++ [new_entry]

    changeset =
      stored_changeset
      |> Ecto.Changeset.change(%{transaction_data: %{transaction_data | entries: entries}})

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("validate", %{"event_map" => params}, socket) do
    params = Map.put(params, "instance_id", socket.assigns.instance.id)
    changeset =
      %EventMap{}
      |> EventMap.changeset(params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("account_changed", %{"event_map" => params}, socket) do
    entries = get_in(params, ["transaction_data", "entries"])
    stored_transaction_data = Ecto.Changeset.get_field(socket.assigns.changeset, :transaction_data)

    if entries && is_map(entries) do

      new_entries = create_new_entries(entries, stored_transaction_data.entries, socket.assigns.accounts)

      changeset =
        socket.assigns.changeset
        |> Ecto.Changeset.change(%{transaction_data: %{stored_transaction_data | entries: new_entries}})

      {:noreply, assign(socket, changeset: changeset)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("save", %{"event_map" => params}, socket) do
    params = Map.put(params, "instance_id", socket.assigns.instance.id)
    case create_event(params) do
      {:ok, message} ->
        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/instances/#{socket.assigns.instance.id}")}

      {:error, message, changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, message)}
    end
  end

  defp create_new_entries(param_entries, entries, accounts) do
    entries_with_indices = Enum.map(param_entries, fn {idx_str, entry} ->
      {String.to_integer(idx_str), entry}
    end)

    Enum.with_index(entries)
    |> Enum.map(fn {entry, idx} ->
      f_entry = Enum.find(entries_with_indices, fn {form_idx, _} -> form_idx == idx end)
      case f_entry do
        {_, form_entry} -> update_entry(form_entry, entry, accounts)
        nil -> entry
      end
    end)
  end

  defp update_entry(form_entry, entry, accounts) do
    account_id = Map.get(form_entry, "account_id")
    account = Enum.find(accounts, fn acc -> "#{acc.id}" == account_id end)

    if account do
      # Update the currency for this entry
      %{entry | currency: account.currency}
      |> Map.put(:account_id, account.id)
    else
      entry
    end
  end
end
