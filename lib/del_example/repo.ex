defmodule DelExample.Repo do
  use Ecto.Repo,
    otp_app: :del_example,
    adapter: Ecto.Adapters.Postgres
end
