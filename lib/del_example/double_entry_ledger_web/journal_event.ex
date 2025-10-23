defmodule DelExample.DoubleEntryLedgerWeb.JournalEvent do
  @moduledoc """
  The DoubleEntryLedgerWeb context for JournalEvent.
  """

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
end
