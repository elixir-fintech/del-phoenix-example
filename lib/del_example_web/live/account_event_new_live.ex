defmodule DelExampleWeb.AccountEventNewLive do
  use DelExampleWeb, :live_view

  import DelExample.DoubleEntryLedgerWeb.Event, only: [get_create_event: 2, create_event_no_save_on_error: 1]
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]
  alias DoubleEntryLedger.Account
  alias DoubleEntryLedger.Event.AccountData
  alias DoubleEntryLedger.Event.AccountEventMap

  @currency_dropdown_options Money.Currency.all()
                             |> Enum.map(fn {k, v} ->
                               ["#{v.name} : (#{v.symbol}) : #{v.exponent}": k]
                             end)
                             |> List.flatten()
                             |> Enum.sort()

  @impl true
  def mount(%{"instance_id" => instance_id, "account_id" => account_id}, _session, socket) do
    instance = get_instance!(instance_id)

    event = get_create_event(:account, account_id)
    account = event.account


    changeset =
      AccountEventMap.changeset(
        %AccountEventMap{
          action: :update_account,
          instance_id: instance.id,
          source: event.source,
          source_idempk: event.source_idempk,
          payload: %AccountData{
            description: account.description
          }
        },
        %{}
      )

    {:ok,
     assign(socket,
       changeset: changeset,
       instance: instance,
       options: get_form_options()
     )}
  end

  def mount(%{"instance_id" => instance_id}, _session, socket) do
    instance = get_instance!(instance_id)
    changeset =
      AccountEventMap.changeset(
        %AccountEventMap{
          action: :create_account,
          instance_id: instance.id,
          payload: %AccountData{
            name: "",
            type: :asset,
            currency: :EUR,
            allowed_negative: false
          }
        },
        %{}
      )

    {:ok,
     assign(socket,
       changeset: changeset,
       instance: instance,
       options: get_form_options()
     )}
  end

  @impl true
  def handle_event("save", %{"account_event_map" => params}, socket) do
    params = Map.put(params, "instance_id", socket.assigns.instance.id)

    case create_event_no_save_on_error(params) do
      {:ok, %Account{} = account, message} ->
        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/instances/#{socket.assigns.instance.id}/accounts/#{account.id}")}

      {:error, message, changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, message)}
    end
  end

  @impl true
  def handle_event("validate", %{"account_event_map" => params}, socket) do
    params = Map.put(params, "instance_id", socket.assigns.instance.id)

    changeset =
      %AccountEventMap{}
      |> AccountEventMap.changeset(params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  defp get_form_options do
    %{
      currencies: @currency_dropdown_options,
      actions: DoubleEntryLedger.Event.actions(:account),
      account_types: Account.account_types(),
      boolean: [Yes: true, No: false]
    }
  end
end
