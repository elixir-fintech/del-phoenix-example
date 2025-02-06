defmodule DelExampleWeb.AccountController do
  use DelExampleWeb, :controller

  alias DelExample.DoubleEntryLedgerWeb
  alias DoubleEntryLedger.Account

  def index(conn, _params) do
    accounts = DoubleEntryLedgerWeb.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def new(conn, _params) do
    changeset = DoubleEntryLedgerWeb.change_account(%Account{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    case DoubleEntryLedgerWeb.create_account(account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: ~p"/accounts/#{account}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    account = DoubleEntryLedgerWeb.get_account!(id)
    render(conn, :show, account: account)
  end

  def edit(conn, %{"id" => id}) do
    account = DoubleEntryLedgerWeb.get_account!(id)
    changeset = DoubleEntryLedgerWeb.change_account(account)
    render(conn, :edit, account: account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = DoubleEntryLedgerWeb.get_account!(id)

    case DoubleEntryLedgerWeb.update_account(account, account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: ~p"/accounts/#{account}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, account: account, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = DoubleEntryLedgerWeb.get_account!(id)
    {:ok, _account} = DoubleEntryLedgerWeb.delete_account(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: ~p"/accounts")
  end
end
