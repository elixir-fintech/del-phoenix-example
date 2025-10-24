defmodule DelExample.DoubleEntryLedgerWeb.JournalEvent do
  @moduledoc """
  The DoubleEntryLedgerWeb context for JournalEvent.
  """

  @account_actions [:create_account, :update_account]
  @trx_actions [:create_transaction, :update_transaction]

  alias DoubleEntryLedger.{Account, Transaction, JournalEvent}
  alias DoubleEntryLedger.Stores.JournalEventStore

  def get_event(instance_address, id) do
    JournalEventStore.get_by_instance_address_and_id(instance_address, id)
  end

  def list_events(instance_id) do
    JournalEventStore.list_all_for_instance_id(instance_id, 1, 1000)
  end

  def list_events_for_account(account_id) do
    JournalEventStore.list_all_for_account_id(account_id)
  end

  def list_events_for_transaction(transaction_id) do
    JournalEventStore.list_all_for_transaction_id(transaction_id)
  end

  def get_related_events(event), do: get_related_events(event, :all)

  def get_related_events(%{action: action} = event, :same_type)
      when action in @account_actions,
      do: get_related_events(event, :account)

  def get_related_events(%{action: action} = event, :same_type)
      when action in @trx_actions,
      do: get_related_events(event, :transaction)

  def get_related_events(%JournalEvent{id: id} = event, :account) do
    case event.account do
      %Account{} = account ->
        Enum.filter(list_events_for_account(account.id), fn
          e -> e.id != id && e.event_map.action not in @trx_actions
        end)

      _ ->
        []
    end
  end

  def get_related_events(%JournalEvent{id: id} = event, :transaction) do
    case event.transaction do
      %Transaction{} = trx ->
        Enum.filter(list_events_for_transaction(trx.id), fn
          e -> e.id != id && e.event_map.action not in @account_actions
        end)

      _ ->
        []
    end
  end

  def get_related_events(event, :all),
    do: get_related_events(event, :transaction) ++ get_related_events(event, :account)
end
