defmodule DelExample.DoubleEntryLedgerWeb.Instance do
  @moduledoc """
  The DoubleEntryLedgerWeb context.
  """

  #import Ecto.Query, warn: false

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

  def validate_instance(%Instance{} = instance) do
    {:ok, sums} = InstanceStore.sum_accounts_debits_and_credits_by_currency(instance.id)
    sums
  end
end
