defmodule DelExample.DoubleEntryLedgerWebTest do
  use DelExample.DataCase

  alias DelExample.DoubleEntryLedgerWeb

  describe "instances" do
    alias DelExample.DoubleEntryLedgerWeb.Instance

    import DelExample.DoubleEntryLedgerWebFixtures

    @invalid_attrs %{}

    test "list_instances/0 returns all instances" do
      instance = instance_fixture()
      assert DoubleEntryLedgerWeb.list_instances() == [instance]
    end

    test "get_instance!/1 returns the instance with given id" do
      instance = instance_fixture()
      assert DoubleEntryLedgerWeb.get_instance!(instance.id) == instance
    end

    test "create_instance/1 with valid data creates a instance" do
      valid_attrs = %{}

      assert {:ok, %Instance{} = instance} = DoubleEntryLedgerWeb.create_instance(valid_attrs)
    end

    test "create_instance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DoubleEntryLedgerWeb.create_instance(@invalid_attrs)
    end

    test "update_instance/2 with valid data updates the instance" do
      instance = instance_fixture()
      update_attrs = %{}

      assert {:ok, %Instance{} = instance} =
               DoubleEntryLedgerWeb.update_instance(instance, update_attrs)
    end

    test "update_instance/2 with invalid data returns error changeset" do
      instance = instance_fixture()

      assert {:error, %Ecto.Changeset{}} =
               DoubleEntryLedgerWeb.update_instance(instance, @invalid_attrs)

      assert instance == DoubleEntryLedgerWeb.get_instance!(instance.id)
    end

    test "delete_instance/1 deletes the instance" do
      instance = instance_fixture()
      assert {:ok, %Instance{}} = DoubleEntryLedgerWeb.delete_instance(instance)
      assert_raise Ecto.NoResultsError, fn -> DoubleEntryLedgerWeb.get_instance!(instance.id) end
    end

    test "change_instance/1 returns a instance changeset" do
      instance = instance_fixture()
      assert %Ecto.Changeset{} = DoubleEntryLedgerWeb.change_instance(instance)
    end
  end

  describe "accounts" do
    alias DelExample.DoubleEntryLedgerWeb.Account

    import DelExample.DoubleEntryLedgerWebFixtures

    @invalid_attrs %{}

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert DoubleEntryLedgerWeb.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert DoubleEntryLedgerWeb.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      valid_attrs = %{}

      assert {:ok, %Account{} = account} = DoubleEntryLedgerWeb.create_account(valid_attrs)
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DoubleEntryLedgerWeb.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      update_attrs = %{}

      assert {:ok, %Account{} = account} =
               DoubleEntryLedgerWeb.update_account(account, update_attrs)
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()

      assert {:error, %Ecto.Changeset{}} =
               DoubleEntryLedgerWeb.update_account(account, @invalid_attrs)

      assert account == DoubleEntryLedgerWeb.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = DoubleEntryLedgerWeb.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> DoubleEntryLedgerWeb.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = DoubleEntryLedgerWeb.change_account(account)
    end
  end

  describe "transactions" do
    alias DelExample.DoubleEntryLedgerWeb.Transaction

    import DelExample.DoubleEntryLedgerWebFixtures

    @invalid_attrs %{}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert DoubleEntryLedgerWeb.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert DoubleEntryLedgerWeb.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{}

      assert {:ok, %Transaction{} = transaction} =
               DoubleEntryLedgerWeb.create_transaction(valid_attrs)
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DoubleEntryLedgerWeb.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      update_attrs = %{}

      assert {:ok, %Transaction{} = transaction} =
               DoubleEntryLedgerWeb.update_transaction(transaction, update_attrs)
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               DoubleEntryLedgerWeb.update_transaction(transaction, @invalid_attrs)

      assert transaction == DoubleEntryLedgerWeb.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = DoubleEntryLedgerWeb.delete_transaction(transaction)

      assert_raise Ecto.NoResultsError, fn ->
        DoubleEntryLedgerWeb.get_transaction!(transaction.id)
      end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = DoubleEntryLedgerWeb.change_transaction(transaction)
    end
  end
end
