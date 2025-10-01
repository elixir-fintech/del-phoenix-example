defmodule DelExampleWeb.AccountNewLive do
  use DelExampleWeb, :live_view

  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]
  alias DoubleEntryLedger.Account
  alias DoubleEntryLedger.Event.AccountData
  alias DelExample.DoubleEntryLedgerWeb.Account, as: DelAccount

  @currency_dropdown_options Money.Currency.all()
                             |> Enum.map(fn {k, v} ->
                               ["#{v.name} : (#{v.symbol}) : #{v.exponent}": k]
                             end)
                             |> List.flatten()
                             |> Enum.sort()

  @impl true
  def mount(%{"instance_address" => instance_address}, _session, socket) do
    instance = get_instance!(instance_address)

    changeset =
      AccountData.changeset(
          %AccountData{
            name: "",
            type: nil,
            currency: :EUR,
            allowed_negative: false
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
  def handle_event("save", %{"account_data" => params}, socket) do
    instance = socket.assigns.instance

    case DelAccount.create(instance.address, params) do
      {:ok, account} ->
        {:noreply,
         socket
         |> assign(account: account)
         |> put_flash(:info, "Account #{account.address} created")
         |> push_navigate(to: ~p"/instances/#{socket.assigns.instance.address}/accounts/#{account.address}")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, "Errors: #{inspect(changeset.errors)}")}
    end
  end

  @impl true
  def handle_event("validate", %{"account_data" => params}, socket) do
    changeset =
      %AccountData{}
      |> AccountData.update_changeset(params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  defp get_form_options do
    %{
      currencies: @currency_dropdown_options,
      account_types: Account.account_types(),
      boolean: [Yes: true, No: false]
    }
  end
end
