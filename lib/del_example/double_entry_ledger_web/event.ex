defmodule DelExample.DoubleEntryLedgerWeb.Event do
  @moduledoc """
  The DoubleEntryLedgerWeb context for Event.
  """

  alias Ecto.Changeset
  alias DoubleEntryLedger.Event
  alias DoubleEntryLedger.Event.EventMap
  alias DoubleEntryLedger.Event.TransactionData
  alias DoubleEntryLedger.Event.EntryData
  alias DoubleEntryLedger.EventStore

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
    case EventStore.process_from_event_params(event_params) do
      {:ok, %{id: trx_id}, %{id: event_id, action: action}} ->
        {:ok, "#{action} event with ID #{event_id}) processed transaction with ID #{trx_id}"}

      {:error, %Changeset{} = event_map_changeset} ->
        errors = get_all_changeset_errors(event_map_changeset)
        {:error, "Error processing event. Event was not saved. #{Jason.encode!(errors)}", event_map_changeset}

      {:error, %Event{id: id, errors: errors}} ->
        {:error, "Error processing saved event with ID #{id}: #{inspect(errors)}", event_map_changeset()}

      {:error, error} ->
        {:error, "Unexpected error processing event: #{inspect(error)}", event_map_changeset()}
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
