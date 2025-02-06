defmodule DelExampleWeb.AccountController do
  use DelExampleWeb, :controller

  alias DelExample.DoubleEntryLedgerWeb
  alias DoubleEntryLedger.Account

  def index(conn, %{"instance_id" => instance_id}) do
    list = case DoubleEntryLedgerWeb.list_accounts(instance_id) do
      {:ok, accounts} -> accounts
      {:error, _} -> []
    end
    render(conn, :index, accounts: list, instance_id: instance_id)
  end

  def new(conn, %{"instance_id" => instance_id}) do
    changeset = DoubleEntryLedgerWeb.change_account(%Account{})
    render(conn, :new, changeset: changeset, instance_id: instance_id)
  end

  def create(conn, %{"account" => account_params, "instance_id" => instance_id}) do
    account_params = Map.put(account_params, "instance_id", instance_id)
    case DoubleEntryLedgerWeb.create_account(account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: ~p"/instances/#{instance_id}/accounts/#{account}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "instance_id" => instance_id}) do
    account = DoubleEntryLedgerWeb.get_account!(id)
    render(conn, :show, account: account, instance_id: instance_id)
  end

  def edit(conn, %{"id" => id, "instance_id" => instance_id}) do
    account = DoubleEntryLedgerWeb.get_account!(id)
    changeset = DoubleEntryLedgerWeb.change_account(account)
    render(conn, :edit, account: account, changeset: changeset, instance_id: instance_id)
  end

  def update(conn, %{"id" => id, "account" => account_params, "instance_id" => instance_id}) do
    account = DoubleEntryLedgerWeb.get_account!(id)

    case DoubleEntryLedgerWeb.update_account(account, account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: ~p"/instances/#{instance_id}/accounts/#{account}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, account: account, changeset: changeset, instance_id: instance_id)
    end
  end

  def delete(conn, %{"id" => id, "instance_id" => instance_id}) do
    account = DoubleEntryLedgerWeb.get_account!(id)
    {:ok, _account} = DoubleEntryLedgerWeb.delete_account(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: ~p"/instances/#{instance_id}/accounts")
  end
end
