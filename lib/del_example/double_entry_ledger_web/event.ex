defmodule DelExample.DoubleEntryLedgerWeb.Event do
  @moduledoc """
  The DoubleEntryLedgerWeb context for Event.
  """

  alias Ecto.Changeset
  alias DoubleEntryLedger.Event.{TransactionEventMap, TransactionData, EntryData}
  alias DoubleEntryLedger.{Account, Transaction, Event}
  alias DoubleEntryLedger.Stores.EventStore
  alias DoubleEntryLedger.Apis.EventApi

  @account_actions [:create_account, :update_account]
  @trx_actions [:create_transaction, :update_transaction]

  def list_events(instance_id) do
    EventStore.list_all_for_instance_id(instance_id, 1, 1000)
  end

  def list_events_for_transaction(transaction_id) do
    EventStore.list_all_for_transaction_id(transaction_id)
  end

  def list_events_for_account(account_id) do
    EventStore.list_all_for_account_id(account_id)
  end

  def get_event(instance_address, id) do
    EventStore.get_by_instance_address_and_id(instance_address, id)
  end

  def get_related_events(event), do: get_related_events(event, :all)

  def get_related_events(%{action: action} = event, :same_type)
    when action in @account_actions, do: get_related_events(event, :account)

  def get_related_events(%{action: action} = event, :same_type)
    when action in @trx_actions, do: get_related_events(event, :transaction)

  def get_related_events(%Event{id: id} = event, :account) do
    case event.account do
      %Account{} = account ->
        Enum.filter(list_events_for_account(account.id), fn
          e -> e.id != id && e.action not in @trx_actions
        end)

      _ -> []
    end
  end

  def get_related_events(%Event{id: id} = event, :transaction) do
    case event.transactions do
      [] -> []

      [trx | _] ->
        Enum.filter(list_events_for_transaction(trx.id), fn
          e -> e.id != id && e.action not in @account_actions
        end)
    end
  end

  def get_related_events(event, :all),
    do: get_related_events(event, :transaction) ++ get_related_events(event, :account)


  def get_create_event(:account, account_id), do: EventStore.get_create_account_event(account_id)

  def get_create_event(:transaction, transaction_id),
    do: EventStore.get_create_transaction_event(transaction_id)

  @spec create_event_no_save_on_error(map()) ::
          {:ok, Account.t() | Transaction.t(), String.t()} | {:error, String.t(), Changeset.t()}
  def create_event_no_save_on_error(event_params) do
    case EventApi.process_from_params(event_params, [on_error: :fail]) do
      {:ok, %Transaction{} = trx, event} ->
        {:ok, trx,
         "#{event.action} event with ID #{event.id}) processed transaction with ID #{trx.id}"}

      {:error, %Changeset{} = event_map_changeset} ->
        errors = get_all_changeset_errors(event_map_changeset)

        {:error, "Error processing event. Event was not saved. #{Jason.encode!(errors)}",
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
