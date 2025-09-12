defmodule DelExample.DoubleEntryLedgerWeb.Event do
  @moduledoc """
  The DoubleEntryLedgerWeb context for Event.
  """

  alias Ecto.Changeset
  alias DoubleEntryLedger.Event.TransactionEventMap
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

  @spec create_event_no_save_on_error(map()) ::
          {:ok, String.t()} | {:error, String.t(), Changeset.t()}
  def create_event_no_save_on_error(event_params) do
    case EventStore.process_from_event_params_no_save_on_error(event_params) do
      {:ok, trx, event} ->
        {:ok,
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
