defmodule DelExampleWeb.EventNewLive do
  use DelExampleWeb, :live_view

  import DelExample.DoubleEntryLedgerWeb.Event
  import DelExample.DoubleEntryLedgerWeb.Account, only: [list_accounts: 1]
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]
  alias DoubleEntryLedger.Event.{EntryData, TransactionData, TransactionEventMap}

  @currency_dropdown_options Money.Currency.all()
                             |> Enum.map(fn {k, v} ->
                               ["#{v.name} : (#{v.symbol}) : #{v.exponent}": k]
                             end)
                             |> List.flatten()
                             |> Enum.sort()

  @impl true
  def mount(%{"instance_id" => instance_id, "trx_id" => trx_id}, _session, socket) do
    instance = get_instance!(instance_id)

    event = get_create_event(:transaction, trx_id)
    [trx | _] = event.transactions

    changeset =
      TransactionEventMap.changeset(
        %TransactionEventMap{
          action: :update_transaction,
          instance_address: instance.address,
          source: event.source,
          source_idempk: event.source_idempk,
          payload: %TransactionData{
            status: trx.status,
            entries:
              Enum.map(trx.entries, fn e ->
                %EntryData{
                  account_id: e.account_id,
                  currency: e.value.currency,
                  amount: e.value.amount
                }
              end)
          }
        },
        %{}
      )

    {:ok,
     assign(socket,
       instance: instance,
       accounts: get_accounts(instance_id),
       options: get_form_options(instance_id),
       changeset: changeset
     )}
  end

  def mount(%{"instance_id" => instance_id}, _session, socket) do
    instance = get_instance!(instance_id)

    changeset =
      TransactionEventMap.changeset(
        %TransactionEventMap{
          action: :create_transaction,
          instance_address: instance.address,
          payload: %TransactionData{status: :posted, entries: []}
        },
        %{}
      )

    {:ok,
     assign(socket,
       instance: instance,
       accounts: get_accounts(instance_id),
       options: get_form_options(instance_id),
       changeset: changeset
     )}
  end

  @impl true
  def handle_event("add-entry", _params, socket) do
    stored_changeset = socket.assigns.changeset
    [account | _] = socket.assigns.accounts
    transaction_data = Ecto.Changeset.get_field(stored_changeset, :payload)
    new_entry = %EntryData{account_id: account.id, currency: account.currency}
    entries = transaction_data.entries ++ [new_entry]

    changeset =
      stored_changeset
      |> Ecto.Changeset.change(%{payload: %{transaction_data | entries: entries}})

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("validate", %{"transaction_event_map" => params}, socket) do
    params = Map.put(params, "instance_address", socket.assigns.instance.address)

    changeset =
      %TransactionEventMap{}
      |> TransactionEventMap.changeset(params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("account_changed", %{"transaction_event_map" => params}, socket) do
    entries = get_in(params, ["payload", "entries"])

    stored_transaction_data =
      Ecto.Changeset.get_field(socket.assigns.changeset, :payload)

    if entries && is_map(entries) do
      new_entries =
        create_new_entries(entries, stored_transaction_data.entries, socket.assigns.accounts)

      changeset =
        socket.assigns.changeset
        |> Ecto.Changeset.change(%{
          payload: %{stored_transaction_data | entries: new_entries}
        })

      {:noreply, assign(socket, changeset: changeset)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("save", %{"transaction_event_map" => params}, socket) do
    params = Map.put(params, "instance_address", socket.assigns.instance.address)

    case create_event_no_save_on_error(params) do
      {:ok, trx, message} ->
        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/instances/#{socket.assigns.instance.id}/transactions/#{trx.id}")}

      {:error, message, changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, message)}
    end
  end

  defp create_new_entries(param_entries, entries, accounts) do
    entries_with_indices =
      Enum.map(param_entries, fn {idx_str, entry} ->
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

  defp get_accounts(instance_id) do
    case list_accounts(instance_id) do
      {:ok, accounts} -> accounts
      {:error, _reason} -> []
    end
  end

  defp get_form_options(instance_id) do
    %{
      accounts:
        Enum.map(get_accounts(instance_id), fn acc -> ["#{acc.address}  (#{acc.type})": acc.id] end)

        |> List.flatten(),
      actions: DoubleEntryLedger.Event.actions(:transaction),
      states: DoubleEntryLedger.Transaction.states(),
      currencies: @currency_dropdown_options
    }
  end
end
