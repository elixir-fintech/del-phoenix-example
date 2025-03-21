defmodule DelExample.DoubleEntryLedgerWeb do
  @moduledoc """
  The DoubleEntryLedgerWeb context.
  """

  #import Ecto.Query, warn: false

  alias DoubleEntryLedger.Account
  alias DoubleEntryLedger.AccountStore

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts(instance_id), do: AccountStore.get_all_accounts_by_instance_id(instance_id)

  @doc """
  Gets a single account.

  Raises if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

  """
  def get_account!(id), do: AccountStore.get_by_id(id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, ...}

  """
  def create_account(attrs \\ %{}), do: AccountStore.create(attrs)

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, ...}

  """
  def update_account(%Account{id: id}, attrs), do: AccountStore.update(id, attrs)

  @doc """
  Deletes a Account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, ...}

  """
  def delete_account(%Account{id: id}), do: AccountStore.delete(id)

  @doc """
  Returns a data structure for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Todo{...}

  """
  def change_account(%Account{} = account, attrs \\ %{}), do: Account.changeset(account, attrs)

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

  alias DoubleEntryLedger.EventStore

  def list_events(instance_id) do
    EventStore.list_all_for_instance(instance_id, 1, 1000)
  end
end
