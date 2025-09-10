defmodule DelExampleWeb.AccountEventNewLive do
  use DelExampleWeb, :live_view

  import DelExample.DoubleEntryLedgerWeb.Event, only: [create_event_no_save_on_error: 1]
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
            currency: :EUR
          }
        },
        %{}
      )

    options = %{
      currencies: @currency_dropdown_options,
      actions: DoubleEntryLedger.Event.actions(),
      account_types: Account.account_types()
    }

    {:ok,
     assign(socket,
       changeset: changeset,
       instance: instance,
       options: options
     )}
  end

  @impl true
  def handle_event("save", %{"account_event_map" => params}, socket) do
    params = Map.put(params, "instance_id", socket.assigns.instance.id)

    case create_event_no_save_on_error(params) do
      {:ok, message} ->
        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: ~p"/instances/#{socket.assigns.instance.id}")}

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
end
