defmodule DelExampleWeb.EventController do
  use DelExampleWeb, :controller

  alias Ecto.Changeset
  alias DoubleEntryLedger.Event.EventMap
  alias DoubleEntryLedger.EventWorker
  alias DoubleEntryLedger.Event.TransactionData
  alias DoubleEntryLedger.Event.EntryData
  alias DoubleEntryLedger.AccountStore

  def new(conn, %{"instance_id" => instance_id}) do
    changeset = event_map_changeset()
    render(conn, :new, changeset: changeset, instance_id: instance_id, accounts: accounts(instance_id))
  end

  def create(conn, %{"event_map" => event_params, "instance_id" => instance_id}) do
    event_params = Map.put(event_params, "instance_id", instance_id)

    case EventMap.create(event_params) do
      {:ok, event_map} -> case EventWorker.process_new_event(event_map) do
        {:ok, _transaction, _event} ->
          conn
          |> put_flash(:info, "Event processed successfully.")
          |> redirect(to: ~p"/instances/#{instance_id}")

        {:error, %Changeset{} = event_changeset} ->
          # this moves the top level errors from the event_changeset to the event_map_changeset
          # so they are displayed in the form. Event though this is for event_map, an abstraction for events,
          # ultimately we are creating events and we want to show the errors in the form.
          em_changeset = event_map_changeset_from_event_changeset(event_params, event_changeset)
          put_flash(conn, :error, "ERROR processing event. #{inspect(event_changeset)}")
          |> render(:new, changeset: em_changeset, instance_id: instance_id, accounts: accounts(instance_id))

        {:error, error} ->
          put_flash(conn, :error, "Error processing event. #{inspect(error)}")
          |> render(:new, changeset: event_map_changeset(), instance_id: instance_id, accounts: accounts(instance_id))
      end

      {:error, %Changeset{} = changeset} ->
        put_flash(conn, :error, "Error processing event. #{inspect(changeset)}")
        |> render(:new, changeset: changeset, instance_id: instance_id, accounts: accounts(instance_id))
    end
  end

  defp event_map_changeset() do
    %EventMap{
      transaction_data: %TransactionData{
        status: :posted,
        entries: [%EntryData{currency: :EUR}, %EntryData{currency: :EUR}]}
    }
    |> EventMap.changeset(%{})
  end

  defp accounts(instance_id) do
    {:ok, accounts} = AccountStore.get_all_accounts_by_instance_id(instance_id)
    Enum.map(accounts, fn account -> [account.name, Atom.to_string(account.type), account.id] end)
  end

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
