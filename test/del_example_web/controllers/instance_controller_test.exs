defmodule DelExampleWeb.InstanceControllerTest do
  use DelExampleWeb.ConnCase

  import DelExample.DoubleEntryLedgerWebFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all instances", %{conn: conn} do
      conn = get(conn, ~p"/instances")
      assert html_response(conn, 200) =~ "Listing Instances"
    end
  end

  describe "new instance" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/instances/new")
      assert html_response(conn, 200) =~ "New Instance"
    end
  end

  describe "create instance" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/instances", instance: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/instances/#{id}"

      conn = get(conn, ~p"/instances/#{id}")
      assert html_response(conn, 200) =~ "Instance #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/instances", instance: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Instance"
    end
  end

  describe "edit instance" do
    setup [:create_instance]

    test "renders form for editing chosen instance", %{conn: conn, instance: instance} do
      conn = get(conn, ~p"/instances/#{instance}/edit")
      assert html_response(conn, 200) =~ "Edit Instance"
    end
  end

  describe "update instance" do
    setup [:create_instance]

    test "redirects when data is valid", %{conn: conn, instance: instance} do
      conn = put(conn, ~p"/instances/#{instance}", instance: @update_attrs)
      assert redirected_to(conn) == ~p"/instances/#{instance}"

      conn = get(conn, ~p"/instances/#{instance}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, instance: instance} do
      conn = put(conn, ~p"/instances/#{instance}", instance: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Instance"
    end
  end

  describe "delete instance" do
    setup [:create_instance]

    test "deletes chosen instance", %{conn: conn, instance: instance} do
      conn = delete(conn, ~p"/instances/#{instance}")
      assert redirected_to(conn) == ~p"/instances"

      assert_error_sent 404, fn ->
        get(conn, ~p"/instances/#{instance}")
      end
    end
  end

  defp create_instance(_) do
    instance = instance_fixture()
    %{instance: instance}
  end
end
