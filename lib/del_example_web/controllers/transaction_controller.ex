defmodule DelExampleWeb.TransactionController do
  use DelExampleWeb, :controller

  alias DelExample.DoubleEntryLedgerWeb


  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, %{"instance_id" => instance_id, "account_id" => account_id}) do
    account = DoubleEntryLedgerWeb.get_account!(account_id)
    transactions = DoubleEntryLedgerWeb.list_transactions(instance_id, account_id)
    render(conn, :index_account, transactions: transactions, instance_id: instance_id, account: account)
  end

  def index(conn, %{"instance_id" => instance_id}) do
    transactions = DoubleEntryLedgerWeb.list_transactions(instance_id)
    render(conn, :index, transactions: transactions, instance_id: instance_id)
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    transaction = DoubleEntryLedgerWeb.get_transaction!(id)
    render(conn, :show, transaction: transaction)
  end
end
