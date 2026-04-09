defmodule DelExampleWeb.PageController do
  use DelExampleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
