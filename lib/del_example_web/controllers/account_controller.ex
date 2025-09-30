defmodule DelExampleWeb.AccountController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Account
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]

  alias DelExample.DoubleEntryLedgerWeb.Event

  def show(conn, %{"address" => address, "instance_id" => instance_id}) do
    instance = get_instance!(instance_id)
    account = get_account!(instance.address, address)
    balance_history = get_balance_history(account.id)
    events = Event.list_events_for_account(account.id)

    render(conn, :show,
      account: account,
      instance: instance,
      instance_id: instance_id,
      events: events,
      balance_history: balance_history
    )
  end

  def delete(conn, %{"address" => address, "instance_id" => instance_id}) do
    instance = get_instance!(instance_id)
    account = get_account!(instance.address, address)

    case delete_account(account) do
      {:ok, %{id: id}} -> put_flash(conn, :info, "Account #{id} deleted successfully.")
      {:error, changeset} -> put_flash(conn, :error, inspect(changeset.errors))
    end
    |> redirect(to: ~p"/instances/#{instance_id}")

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: ~p"/instances/#{instance_id}/accounts")
  end
end
