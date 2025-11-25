defmodule DelExample.Fixtures do
  @moduledoc false

  alias DoubleEntryLedger.{Account, Instance, Repo}
  alias DoubleEntryLedger.Stores.{InstanceStore, TransactionStore}

  def instance_fixture(attrs \\ %{}) do
    suffix = unique_suffix()

    attrs =
      Map.merge(
        %{
          address: "instance#{suffix}",
          description: "Fixture instance #{suffix}"
        },
        attrs
      )

    {:ok, instance} = InstanceStore.create(attrs)
    instance
  end

  def account_fixture(%Instance{} = instance, attrs \\ %{}) do
    suffix = unique_suffix()

    defaults = %{
      name: "Account #{suffix}",
      address: "acct#{suffix}",
      currency: :EUR,
      type: :asset,
      allowed_negative: false
    }

    attrs =
      defaults
      |> Map.merge(attrs)

    %Account{}
    |> Account.changeset(attrs |> Map.put(:instance_id, instance.id))
    |> Repo.insert!()
  end

  def transaction_fixture(
        %Instance{} = instance,
        %Account{} = debit_account,
        %Account{} = credit_account,
        attrs \\ %{}
      ) do
    suffix = unique_suffix()

    defaults = %{
      status: :posted,
      entries: [
        %{
          account_address: debit_account.address,
          amount: 100,
          currency: debit_account.currency
        },
        %{
          account_address: credit_account.address,
          amount: -100,
          currency: credit_account.currency
        }
      ]
    }

    defaults
    |> Map.merge(attrs)
    |> then(&TransactionStore.create(instance.address, &1, "fixture-trx-#{suffix}", on_error: :fail))
  end

  def unique_suffix do
    System.unique_integer([:positive])
  end
end
