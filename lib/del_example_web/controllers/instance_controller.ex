defmodule DelExampleWeb.InstanceController do
  use DelExampleWeb, :controller

  alias DelExample.DoubleEntryLedgerWeb
  alias DoubleEntryLedger.Instance

  def index(conn, _params) do
    instances = DoubleEntryLedgerWeb.list_instances()
    render(conn, :index, instances: instances)
  end

  def new(conn, _params) do
    changeset = DoubleEntryLedgerWeb.change_instance(%Instance{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"instance" => instance_params}) do
    case DoubleEntryLedgerWeb.create_instance(instance_params) do
      {:ok, instance} ->
        conn
        |> put_flash(:info, "Instance created successfully.")
        |> redirect(to: ~p"/instances/#{instance}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    instance = DoubleEntryLedgerWeb.get_instance!(id)
    list = case DoubleEntryLedgerWeb.list_accounts(id) do
      {:ok, accounts} -> accounts
      {:error, _} -> []
    end
    render(conn, :show, instance: instance, accounts: list)
  end

  def edit(conn, %{"id" => id}) do
    instance = DoubleEntryLedgerWeb.get_instance!(id)
    changeset = DoubleEntryLedgerWeb.change_instance(instance)
    render(conn, :edit, instance: instance, changeset: changeset)
  end

  def update(conn, %{"id" => id, "instance" => instance_params}) do
    instance = DoubleEntryLedgerWeb.get_instance!(id)

    case DoubleEntryLedgerWeb.update_instance(instance, instance_params) do
      {:ok, instance} ->
        conn
        |> put_flash(:info, "Instance updated successfully.")
        |> redirect(to: ~p"/instances/#{instance}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, instance: instance, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    instance = DoubleEntryLedgerWeb.get_instance!(id)
    case DoubleEntryLedgerWeb.delete_instance(instance) do
      {:ok, %{id: id} } -> put_flash(conn, :info, "Instance #{id} deleted successfully.")
      {:error, changeset} -> put_flash(conn, :error, inspect(changeset.errors))
    end
    |> redirect(to: ~p"/instances")
  end
end
