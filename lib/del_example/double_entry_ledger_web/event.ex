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

  def create_event(event_params) do
    case EventMap.create(event_params) do
      {:ok, event_map} -> case EventWorker.process_new_event(event_map) do
        {:ok, _transaction, _event} ->
          {:ok, "Event processed successfully."}

        {:error, %Changeset{} = event_changeset} ->
          {:error, "ERROR processing event. #{inspect(event_changeset)}", event_map_changeset_from_event_changeset(event_params, event_changeset)}

        {:error, error} ->
          {:error, "Error processing event. #{inspect(error)}", event_map_changeset()}
      end

      {:error, %Changeset{} = changeset} ->
        {:error, "Error processing event. #{inspect(changeset)}", changeset}
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

  # this moves the top level errors from the event_changeset to the event_map_changeset
  # so they are displayed in the form. Event though this is for event_map, an abstraction for events,
  # ultimately we are creating events and we want to show the errors in the form.
  defp event_map_changeset_from_event_changeset(event_params, event_changeset) do
    EventMap.changeset(%EventMap{}, event_params)
    |> move_errors(event_changeset)
    |> Map.put(:action, :create)
  end

  defp move_errors(target_changeset, source_changeset) do
    # Traverse errors to get a map of field => list of error messages.
    errors = Ecto.Changeset.traverse_errors(source_changeset, fn {msg, opts} -> {msg, opts} end)

    Enum.reduce(errors, target_changeset, fn {field, messages}, acc ->
      Enum.reduce(messages, acc, fn {msg, opts}, acc2 ->
        Ecto.Changeset.add_error(acc2, field, msg, opts)
      end)
    end)
  end
end
