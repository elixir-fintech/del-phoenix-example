defmodule DelExampleWeb.TransactionControllerTest do
  use DelExampleWeb.ConnCase

  import DelExample.Fixtures

  describe "index scoped to instance" do
    test "shows empty state when no transactions exist", %{conn: conn} do
      instance = instance_fixture()

      conn = get(conn, ~p"/instances/#{instance.address}/transactions")
      body = html_response(conn, 200)

      assert body =~ "Transaction feed"
      assert body =~ "No transactions yet."
    end
  end
end
