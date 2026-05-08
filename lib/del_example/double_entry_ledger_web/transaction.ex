defmodule DelExample.DoubleEntryLedgerWeb.Transaction do
  @moduledoc """
  The DoubleEntryLedgerWeb context for Transaction.
  """
  alias DoubleEntryLedger.Stores.TransactionStore

  def create(instance_address, params) do
    TransactionStore.create(
      instance_address,
      params,
      Nanoid.generate(),
      on_error: :fail
    )
    |> case do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, Ecto.Changeset.get_embed(changeset, :payload)}

      rest ->
        rest
    end
  end

  def update(instance_address, transaction_id, params) do
    TransactionStore.update(
      instance_address,
      transaction_id,
      params,
      Nanoid.generate(),
      on_error: :fail
    )
    |> case do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, Ecto.Changeset.get_embed(changeset, :payload)}

      rest ->
        rest
    end
  end

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions(instance_id) do
    {:ok, {transactions, _meta}} = TransactionStore.list_for_instance(instance_id)
    transactions
  end

  @doc """
  Returns the list of transactions for a given account.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions(instance_id, account_id) do
    {:ok, {rows, _meta}} =
      TransactionStore.list_for_instance_and_account(instance_id, account_id)

    rows
  end

  @doc """
  Gets a single transaction.

  Raises if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

  """
  def get_transaction!(id), do: TransactionStore.get_by_id(id, entries: :account)
end
