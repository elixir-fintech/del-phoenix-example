defmodule DelExampleWeb.InstanceControllerTest do
  use DelExampleWeb.ConnCase

  import DelExample.Fixtures

  describe "index" do
    test "lists instances including fixtures", %{conn: conn} do
      instance = instance_fixture()

      conn = get(conn, ~p"/")
      body = html_response(conn, 200)

      assert body =~ "All instances"
      assert body =~ instance.address
    end
  end

  describe "show" do
    test "renders instance detail with accounts", %{conn: conn} do
      instance = instance_fixture()
      account = account_fixture(instance)

      conn = get(conn, ~p"/instances/#{instance.address}")
      body = html_response(conn, 200)

      assert body =~ instance.address
      assert body =~ account.address
      assert body =~ "Associated Accounts"
    end
  end
end
