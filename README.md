# DelExample

This is a sample phoenix application for the DoubleEntryLedger <https://hex.pm/packages/double_entry_ledger>

## Installation

### Install dependencies

```bash
mix deps.get
```

### Copy database migration files

```bash
cp deps/double_entry_ledger/priv/repo/migrations/* priv/repo/migrations/
```

### Create and migrate the database

```bash
mix ecto.create && mix ecto.migrate
```

### Start the phoenix application

```bash
iex -S mix phx.server
```

You can now access the application under <http://localhost:4000/>
