defmodule DelExampleWeb.AccountEditLive do
  use DelExampleWeb, :live_view

  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]
  alias DoubleEntryLedger.Event.AccountData
  alias DelExample.DoubleEntryLedgerWeb.Account, as: DelAccount

  @impl true
  def mount(%{"instance_address" => instance_address, "account_address" => account_address}, _session, socket) do
    instance = get_instance!(instance_address)
    account = DelAccount.get_account!(instance.address, account_address)

    changeset =
      AccountData.update_changeset(
          %AccountData{
            name: account.name,
            description: account.description
          },
        %{}
      )

    {:ok,
     assign(socket,
       changeset: changeset,
       account: account,
       instance: instance
     )}
  end

  @impl true
  def handle_event("save", %{"account_data" => params}, socket) do
    instance = socket.assigns.instance
    old_account = socket.assigns.account

    case DelAccount.update(instance.address, old_account.address, params) do
      {:ok, account} ->
        {:noreply,
         socket
         |> assign(account: account)
         |> put_flash(:info, "Account #{account.address} updated")
         |> push_navigate(to: ~p"/instances/#{instance.address}/accounts/#{account.address}")}

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
end
