defmodule DelExample.DoubleEntryLedgerWeb do
  @moduledoc """
  The DoubleEntryLedgerWeb context.
  """

  #import Ecto.Query, warn: false


  alias DoubleEntryLedger.EventStore

  def list_events(instance_id) do
    EventStore.list_all_for_instance(instance_id, 1, 1000)
  end
end
