defmodule DelExample.DoubleEntryLedgerWeb do
  @moduledoc """
  The DoubleEntryLedgerWeb context.
  """

  import Ecto.Query, warn: false

  alias DoubleEntryLedger.Instance
  alias DoubleEntryLedger.InstanceStore

  @doc """
  Returns the list of instances.

  ## Examples

      iex> list_instances()
      [%Instance{}, ...]

  """
  def list_instances do
    InstanceStore.list_all()
  end

  @doc """
  Gets a single instance.

  Raises if the Instance does not exist.

  ## Examples

      iex> get_instance!(123)
      %Instance{}

  """
  def get_instance!(id), do: InstanceStore.get_by_id(id)

  @doc """
  Creates a instance.

  ## Examples

      iex> create_instance(%{field: value})
      {:ok, %Instance{}}

      iex> create_instance(%{field: bad_value})
      {:error, ...}

  """
  def create_instance(attrs \\ %{}), do: InstanceStore.create(attrs)

  @doc """
  Updates a instance.

  ## Examples

      iex> update_instance(instance, %{field: new_value})
      {:ok, %Instance{}}

      iex> update_instance(instance, %{field: bad_value})
      {:error, ...}

  """
  def update_instance(%Instance{id: id}, attrs), do: InstanceStore.update(id, attrs)

  @doc """
  Deletes a Instance.

  ## Examples

      iex> delete_instance(instance)
      {:ok, %Instance{}}

      iex> delete_instance(instance)
      {:error, ...}

  """
  def delete_instance(%Instance{id: id}), do: InstanceStore.delete(id)

  @doc """
  Returns a data structure for tracking instance changes.

  ## Examples

      iex> change_instance(instance)
      %Todo{...}

  """
  def change_instance(%Instance{} = instance, attrs \\ %{}), do: Instance.changeset(instance, attrs)

  alias DoubleEntryLedger.Account
  alias DoubleEntryLedger.AccountStore

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    raise "TODO"
  end

  @doc """
  Gets a single account.

  Raises if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

  """
  def get_account!(id), do: raise "TODO"

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, ...}

  """
  def create_account(attrs \\ %{}) do
    raise "TODO"
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, ...}

  """
  def update_account(%Account{} = account, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, ...}

  """
  def delete_account(%Account{} = account) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Todo{...}

  """
  def change_account(%Account{} = account, _attrs \\ %{}) do
    raise "TODO"
  end
end
