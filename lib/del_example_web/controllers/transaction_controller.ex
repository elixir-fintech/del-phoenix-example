defmodule DelExampleWeb.TransactionController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Transaction
  import DelExample.DoubleEntryLedgerWeb.Account, only: [get_account!: 1]
  import DelExample.DoubleEntryLedgerWeb.Event, only: [list_events_for_transaction: 1]
  import DelExample.DoubleEntryLedgerWeb.Instance, only: [get_instance!: 1]

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, %{"instance_id" => instance_id, "account_id" => account_id}) do
    instance = get_instance!(instance_id)
    account = get_account!(account_id)
    transactions = list_transactions(instance_id, account_id)

    render(conn, :index_account,
      transactions: transactions,
      instance_id: instance_id,
      instance: instance,
      account: account
    )
  end

  def index(conn, %{"instance_id" => instance_id}) do
    instance = get_instance!(instance_id)
    transactions = list_transactions(instance.id)
    render(conn, :index, transactions: transactions, instance: instance)
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"instance_id" => instance_id, "id" => id}) do
    instance = get_instance!(instance_id)
    transaction = get_transaction!(id)
    events = list_events_for_transaction(id)
    render(conn, :show, transaction: transaction, events: events, instance: instance)
  end
end
