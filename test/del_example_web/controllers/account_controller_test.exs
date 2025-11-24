defmodule DelExampleWeb.AccountControllerTest do
  use DelExampleWeb.ConnCase

  import DelExample.Fixtures

  describe "show" do
    test "renders account details and navigation links", %{conn: conn} do
      instance = instance_fixture()
      account = account_fixture(instance)

      conn = get(conn, ~p"/instances/#{instance.address}/accounts/#{account.address}")
      body = html_response(conn, 200)

      assert body =~ account.address
      assert body =~ "Transaction History"
      assert body =~ instance.address
    end
  end

  describe "delete" do
    test "removes the account from the instance", %{conn: conn} do
      instance = instance_fixture()
      account = account_fixture(instance)

      conn = delete(conn, ~p"/instances/#{instance.address}/accounts/#{account.address}")
      assert redirected_to(conn) == ~p"/instances/#{instance.address}"
    end
  end
end
