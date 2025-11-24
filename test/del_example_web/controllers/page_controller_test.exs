defmodule DelExampleWeb.PageControllerTest do
  use DelExampleWeb.ConnCase

  import DelExample.Fixtures

  test "GET /", %{conn: conn} do
    instance = instance_fixture()

    conn = get(conn, ~p"/")
    body = html_response(conn, 200)

    assert body =~ "Ledger environments overview"
    assert body =~ instance.address
  end
end
