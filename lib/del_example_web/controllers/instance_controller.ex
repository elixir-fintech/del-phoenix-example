defmodule DelExampleWeb.InstanceController do
  use DelExampleWeb, :controller

  import DelExample.DoubleEntryLedgerWeb.Instance
  import DelExample.DoubleEntryLedgerWeb.Account, only: [list_accounts: 1]
  alias DoubleEntryLedger.Instance

  def index(conn, _params) do
    instances = list_instances()
    render(conn, :index, instances: instances)
  end

  def new(conn, _params) do
    changeset = change_instance(%Instance{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"instance" => instance_params}) do
    case create_instance(instance_params) do
      {:ok, instance} ->
        conn
        |> put_flash(:info, "Instance created successfully.")
        |> redirect(to: ~p"/instances/#{instance}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"address" => address}) do
    instance = get_instance!(address)

    list =
      case list_accounts(instance.id) do
        {:ok, accounts} -> accounts
        {:error, _} -> []
      end

    sums =
      Map.new(validate_instance(instance), fn %{currency: currency} = item ->
        {currency, Map.drop(item, [:currency])}
      end)

    render(conn, :show, instance: instance, accounts: list, sums: sums)
  end

  def edit(conn, %{"address" => address}) do
    instance = get_instance!(address)
    changeset = change_instance(instance)
    render(conn, :edit, instance: instance, changeset: changeset)
  end

  def update(conn, %{"address" => address, "instance" => instance_params}) do
    instance = get_instance!(address)

    case update_instance(instance, instance_params) do
      {:ok, instance} ->
        conn
        |> put_flash(:info, "Instance updated successfully.")
        |> redirect(to: ~p"/instances/#{instance.address}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, instance: instance, changeset: changeset)
    end
  end

  def delete(conn, %{"address" => address}) do
    instance = get_instance!(address)

    case delete_instance(instance) do
      {:ok, %{address: addr}} -> put_flash(conn, :info, "Instance #{addr} deleted successfully.")
      {:error, changeset} -> put_flash(conn, :error, inspect(changeset.errors))
    end
    |> redirect(to: ~p"/instances")
  end
end
