defmodule DelExample.DoubleEntryLedgerWeb.Transaction do
  @moduledoc """
  The DoubleEntryLedgerWeb context for Transaction.
  """
  alias DoubleEntryLedger.TransactionStore

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions(instance_id) do
    TransactionStore.list_all_for_instance(instance_id)
  end

  @doc """
  Returns the list of transactions for a given account.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions(instance_id, account_id) do
    TransactionStore.list_all_for_instance_and_account(instance_id, account_id)
  end

  @doc """
  Gets a single transaction.

  Raises if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

  """
  def get_transaction!(id), do: TransactionStore.get_by_id(id)
end
