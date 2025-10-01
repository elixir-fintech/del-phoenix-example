defmodule DelExampleWeb.TransactionController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Transaction
  import DelExample.DoubleEntryLedgerWeb.Account, only: [get_account!: 2]
  import DelExample.DoubleEntryLedgerWeb.Event, only: [list_events_for_transaction: 1]
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, %{"instance_address" => instance_address, "account_address" => account_address}) do
    instance = get_instance!(instance_address)
    account = get_account!(instance.address, account_address)
    transactions = list_transactions(instance.id, account.id)

    render(conn, :index_account,
      transactions: transactions,
      instance: instance,
      account: account
    )
  end

  def index(conn, %{"instance_address" => instance_address}) do
    instance = get_instance!(instance_address)
    transactions = list_transactions(instance.id)
    render(conn, :index, transactions: transactions, instance: instance)
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"instance_address" => instance_address, "id" => id}) do
    instance = get_instance!(instance_address)
    transaction = get_transaction!(id)
    events = list_events_for_transaction(id)
    render(conn, :show, transaction: transaction, events: events, instance: instance)
  end
end
