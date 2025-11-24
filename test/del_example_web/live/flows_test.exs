defmodule DelExampleWeb.LiveFlowsTest do
  use DelExampleWeb.ConnCase

  import Phoenix.LiveViewTest
  import DelExample.Fixtures

  test "renders the new account live form", %{conn: conn} do
    instance = instance_fixture()

    {:ok, _lv, html} = live(conn, ~p"/instances/#{instance.address}/accounts/new")
    assert html =~ "Create an account for #{instance.address}"
    assert html =~ "Account Name"
  end

  test "renders the new transaction live form with accounts", %{conn: conn} do
    instance = instance_fixture()
    account_fixture(instance, %{type: :asset})
    account_fixture(instance, %{type: :liability, address: "liablive#{unique_suffix()}"})

    {:ok, _lv, html} = live(conn, ~p"/instances/#{instance.address}/transactions/new")
    assert html =~ "New transaction"
    assert html =~ "Transaction status"
    assert html =~ "Account Address"
  end
end
