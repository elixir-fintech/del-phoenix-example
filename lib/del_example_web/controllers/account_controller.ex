defmodule DelExampleWeb.AccountController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Account
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]

  alias DelExample.DoubleEntryLedgerWeb.Event

  def show(conn, %{"address" => address, "instance_address" => instance_address}) do
    instance = get_instance!(instance_address)
    account = get_account!(instance_address, address)
    balance_history = get_balance_history(account.id)
    events = Event.list_events_for_account(account.id)

    render(conn, :show,
      account: account,
      instance: instance,
      events: events,
      balance_history: balance_history
    )
  end

  def delete(conn, %{"address" => address, "instance_address" => instance_address}) do
    instance = get_instance!(instance_address)
    account = get_account!(instance.address, address)

    case delete_account(account) do
      {:ok, %{address: addr}} -> put_flash(conn, :info, "Account #{addr} deleted successfully.")
      {:error, changeset} -> put_flash(conn, :error, inspect(changeset.errors))
    end
    |> redirect(to: ~p"/instances/#{instance}")

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: ~p"/instances/#{instance}")
  end
end
