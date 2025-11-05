defmodule DelExample.DoubleEntryLedgerWeb.Command do
  @moduledoc """
  The DoubleEntryLedgerWeb context for Command.
  """

  alias Ecto.Changeset
  alias DoubleEntryLedger.Command.{TransactionEventMap, TransactionData, EntryData}
  alias DoubleEntryLedger.{Account, Transaction}
  alias DoubleEntryLedger.Stores.{CommandStore, JournalEventStore}
  alias DoubleEntryLedger.Apis.CommandApi

  # @account_actions [:create_account, :update_account]
  # @trx_actions [:create_transaction, :update_transaction]

  def create(event_params) do
    CommandApi.create_from_params(event_params)
  end

  def list_events(instance_id) do
    CommandStore.list_all_for_instance_id(instance_id, 1, 1000)
  end

  def list_events_for_transaction(transaction_id) do
    CommandStore.list_all_for_transaction_id(transaction_id)
  end

  def list_events_for_account(account_id) do
    JournalEventStore.list_all_for_account_id(account_id)
  end

  def get_event(instance_address, id) do
    CommandStore.get_by_instance_address_and_id(instance_address, id)
  end

  def get_create_event(:transaction, transaction_id),
    do: JournalEventStore.get_create_transaction_journal_event(transaction_id)

  @spec create_event_no_save_on_error(map()) ::
          {:ok, Account.t() | Transaction.t(), String.t()} | {:error, String.t(), Changeset.t()}
  def create_event_no_save_on_error(event_params) do
    case CommandApi.process_from_params(event_params, on_error: :fail) do
      {:ok, %Transaction{} = trx, event} ->
        {:ok, trx,
         "#{event.event_map.action} event with ID #{event.id}) processed transaction with ID #{trx.id}"}

      {:error, %Changeset{} = event_map_changeset} ->
        errors = get_all_changeset_errors(event_map_changeset)

        {:error, "Error processing event. Command was not saved. #{Jason.encode!(errors)}",
         event_map_changeset}

      {:error, error} ->
        {:error, "Unexpected error processing event: #{inspect(error)}", event_map_changeset()}
    end
  end

  @spec event_map_changeset() :: Ecto.Changeset.t()
  def event_map_changeset() do
    %TransactionEventMap{
      payload: %TransactionData{
        status: :posted,
        entries: [%EntryData{currency: :EUR}, %EntryData{currency: :EUR}]
      }
    }
    |> TransactionEventMap.changeset(%{})
  end

  def get_all_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
