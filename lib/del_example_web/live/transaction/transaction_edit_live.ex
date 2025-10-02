defmodule DelExampleWeb.TransactionEditLive do
  use DelExampleWeb, :live_view

  alias DoubleEntryLedger.{Repo, Entry}
  import DelExample.DoubleEntryLedgerWeb.Event
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]
  alias DelExample.DoubleEntryLedgerWeb.Transaction
  alias DoubleEntryLedger.Event.{EntryData, TransactionData}

  @impl true
  def mount(%{"instance_address" => instance_address, "transaction_id" => trx_id}, _session, socket) do
    instance = get_instance!(instance_address)

    event = get_create_event(:transaction, trx_id)
    [trx | _] = event.transactions

    trx = Repo.preload(trx, entries: :account)

    changeset =
      TransactionData.update_event_changeset(
        %TransactionData{
          status: trx.status,
          entries:
            Enum.map(trx.entries, fn e ->
              %EntryData{
                account_address: e.account.address,
                currency: e.value.currency,
                amount: Entry.signed_value(e)
              }
            end)
        },
        %{}
      )

    {:ok,
     assign(socket,
       instance: instance,
       transaction: trx,
       states: DoubleEntryLedger.Transaction.states(),
       changeset: changeset
     )}
  end


  @impl true
  def handle_event("validate", %{"transaction_data" => params}, socket) do
    changeset =
      %TransactionData{}
      |> TransactionData.update_event_changeset(params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"transaction_data" => params}, %{assigns: %{instance: i, transaction: t}} = socket) do
    case Transaction.update(i.address, t.id, params) do
      {:ok, trx} ->
        {:noreply,
         socket
         |> assign(transaction: trx)
         |> put_flash(:info, "Transaction #{trx.id} updated")
         |> push_navigate(to: ~p"/instances/#{i}/transactions/#{trx}")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, "Errors: #{inspect(changeset.errors)}")}
    end
  end
end
