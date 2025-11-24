import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :del_example, DelExample.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "del_example_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :double_entry_ledger, DoubleEntryLedger.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "del_example_test#{System.get_env("MIX_TEST_PARTITION")}",
  stacktrace: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true,
  pool_size: System.schedulers_online() * 2

config :double_entry_ledger,
  schema_prefix: "double_entry_ledger",
  idempotency_secret: "123456677890"

config :double_entry_ledger, Oban,
  engine: Oban.Engines.Basic,
  queues: [double_entry_ledger: 10],
  repo: DoubleEntryLedger.Repo,
  prefix: "double_entry_ledger"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :del_example, DelExampleWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "PqCgfQ3XaldYc48SYLXmdlEFxspHVBM1/NN1L0mYkxStV/G4m9OruRTBa9Dtrwvi",
  server: false

# In test we don't send emails
config :del_example, DelExample.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
