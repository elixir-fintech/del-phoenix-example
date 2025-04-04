defmodule DelExample.DoubleEntryLedgerWeb.Event do
  @moduledoc """
  The DoubleEntryLedgerWeb context for Event.
  """

  alias Ecto.Changeset
  alias DoubleEntryLedger.Event.EventMap
  alias DoubleEntryLedger.Event.TransactionData
  alias DoubleEntryLedger.Event.EntryData
  alias DoubleEntryLedger.EventStore
  alias DoubleEntryLedger.EventWorker

  def list_events(instance_id) do
    EventStore.list_all_for_instance(instance_id, 1, 1000)
  end

  def list_events_for_transaction(transaction_id) do
    EventStore.list_all_for_transaction(transaction_id)
  end

  def get_event(id) do
    EventStore.get_by_id(id)
  end

  def create_event(event_params) do
    case EventMap.create(event_params) do
      {:ok, event_map} -> case EventWorker.process_new_event(event_map) do
        {:ok, _transaction, _event} ->
          {:ok, "Event processed successfully."}

        {:error, %Changeset{} = event_map_changeset} ->
          errors = get_all_changeset_errors(event_map_changeset)
          {:error, "ERROR processing event. #{Jason.encode!(errors)}", event_map_changeset}

        {:error, error} ->
          {:error, "Error processing event. #{inspect(error)}", event_map_changeset()}
      end

      {:error, %Changeset{} = changeset} ->
        errors = get_all_changeset_errors(changeset)

        {:error, "Error creating event. #{Jason.encode!(errors)}" , changeset}
    end
  end

  def event_map_changeset() do
    %EventMap{
      transaction_data: %TransactionData{
        status: :posted,
        entries: [%EntryData{currency: :EUR}, %EntryData{currency: :EUR}]}
    }
    |> EventMap.changeset(%{})
  end

  def get_all_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
