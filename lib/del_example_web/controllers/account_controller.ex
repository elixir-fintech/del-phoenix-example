defmodule DelExampleWeb.AccountController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Account
  alias DoubleEntryLedger.Account

  def new(conn, %{"instance_id" => instance_id}) do
    changeset = change_account(%Account{})
    render(conn, :new, changeset: changeset, instance_id: instance_id)
  end

  def create(conn, %{"account" => account_params, "instance_id" => instance_id}) do
    account_params = Map.put(account_params, "instance_id", instance_id)

    case create_account(account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: ~p"/instances/#{instance_id}/accounts/#{account}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset, instance_id: instance_id)
    end
  end

  def show(conn, %{"id" => id, "instance_id" => instance_id}) do
    account = get_account!(id)
    balance_history = get_balance_history(account.id)

    render(conn, :show,
      account: account,
      instance_id: instance_id,
      balance_history: balance_history
    )
  end

  def edit(conn, %{"id" => id, "instance_id" => instance_id}) do
    account = get_account!(id)
    changeset = change_account(account)
    render(conn, :edit, account: account, changeset: changeset, instance_id: instance_id)
  end

  def update(conn, %{"id" => id, "account" => account_params, "instance_id" => instance_id}) do
    account = get_account!(id)

    case update_account(account, account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: ~p"/instances/#{instance_id}/accounts/#{account}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, account: account, changeset: changeset, instance_id: instance_id)
    end
  end

  def delete(conn, %{"id" => id, "instance_id" => instance_id}) do
    account = get_account!(id)

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
