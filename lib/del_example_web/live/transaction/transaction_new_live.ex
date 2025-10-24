defmodule DelExampleWeb.TransactionNewLive do
  use DelExampleWeb, :live_view

  import DelExample.DoubleEntryLedgerWeb.Account, only: [list_accounts: 1, get_account!: 2]
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]
  alias DoubleEntryLedger.Event.{EntryData, TransactionData}
  alias DelExample.DoubleEntryLedgerWeb.Transaction

  @currency_dropdown_options Money.Currency.all()
                             |> Enum.map(fn {k, v} ->
                               ["#{v.name} : (#{v.symbol}) : #{v.exponent}": k]
                             end)
                             |> List.flatten()
                             |> Enum.sort()

  @impl true
  def mount(
        %{"instance_address" => instance_address, "account_address" => address},
        _session,
        socket
      ) do
    instance = get_instance!(instance_address)
    account = get_account!(instance_address, address)

    changeset =
      get_changeset([
        %EntryData{account_address: account.address, amount: nil, currency: account.currency},
        %EntryData{account_address: nil, amount: nil, currency: nil}
      ])

    {:ok, create_assigns(socket, instance, changeset)}
  end

  def mount(%{"instance_address" => instance_address}, _session, socket) do
    instance = get_instance!(instance_address)

    changeset =
      get_changeset([
        %EntryData{account_address: nil, amount: nil, currency: nil},
        %EntryData{account_address: nil, amount: nil, currency: nil}
      ])

    {:ok, create_assigns(socket, instance, changeset)}
  end

  def get_changeset(entries, status \\ :posted) do
    TransactionData.changeset(
      %TransactionData{
        status: status,
        entries: entries
      },
      %{}
    )
  end

  def create_assigns(socket, instance, changeset) do
    assign(socket,
      instance: instance,
      accounts: get_accounts(instance.id),
      options: get_form_options(instance.id),
      changeset: changeset
    )
  end

  @impl true
  def handle_event("add-entry", _params, %{assigns: %{changeset: cs}} = socket) do
    current_entries = Ecto.Changeset.get_field(cs, :entries)
    new_entry = %EntryData{account_address: nil, amount: nil, currency: nil}
    entries = current_entries ++ [new_entry]

    changeset =
      cs
      |> Ecto.Changeset.change(%{entries: entries})

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("validate", %{"transaction_data" => params}, socket) do
    changeset =
      %TransactionData{}
      |> TransactionData.changeset(params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "account_changed",
        %{"transaction_data" => params},
        %{assigns: %{changeset: cs, accounts: accs}} = socket
      ) do
    entries = get_in(params, ["entries"])

    stored_entries =
      Ecto.Changeset.get_field(cs, :entries)

    if entries && is_map(entries) do
      new_entries =
        create_new_entries(entries, stored_entries, accs)

      changeset =
        cs
        |> Ecto.Changeset.change(%{entries: new_entries})

      {:noreply, assign(socket, changeset: changeset)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "save",
        %{"transaction_data" => params},
        %{assigns: %{instance: instance}} = socket
      ) do
    case Transaction.create(instance.address, params) do
      {:ok, trx} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction: #{trx.id} created")
         |> push_navigate(to: ~p"/instances/#{instance.address}/transactions/#{trx.id}")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, "Errors: #{inspect(changeset.errors)}")}
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
    account_address = Map.get(form_entry, "account_address")
    account = Enum.find(accounts, fn acc -> "#{acc.address}" == account_address end)

    if account do
      # Update the currency for this entry
      %{entry | currency: account.currency}
      |> Map.put(:account_address, account.address)
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
        Enum.map(get_accounts(instance_id), fn acc ->
          ["#{acc.address}  (#{acc.type})": acc.address]
        end)
        |> List.flatten(),
      states: Enum.reject(DoubleEntryLedger.Transaction.states(), &(&1 == :archived)),
      currencies: @currency_dropdown_options
    }
  end
end
