defmodule DelExample.DoubleEntryLedgerWeb.Account do
  @moduledoc """
  The DoubleEntryLedgerWeb context.
  """

  # import Ecto.Query, warn: false

  alias DoubleEntryLedger.Account
  alias DoubleEntryLedger.Stores.AccountStore

  def create(instance_address, params) do
    case AccountStore.create(instance_address, params, "portal_create_account") do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, Ecto.Changeset.get_embed(changeset, :payload)}

      rest ->
        rest
    end
  end

  def update(instance_address, address, params) do
    case AccountStore.update(instance_address, address, params, "portal_update_account") do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, Ecto.Changeset.get_embed(changeset, :payload)}

      rest ->
        rest
    end
  end

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
  def get_account!(instance_address, address),
    do: AccountStore.get_by_address(instance_address, address)

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
  def get_balance_history(account_id) do
    {:ok, balance} = AccountStore.get_balance_history_by_id(account_id)
    balance
  end
end
