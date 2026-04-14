# DelExample

A sample Phoenix 1.8 application for the [DoubleEntryLedger](https://hex.pm/packages/double_entry_ledger) library, showcasing command-sourced double-entry bookkeeping with DaisyUI components.

## Prerequisites

- Elixir 1.17+
- PostgreSQL 14+

## Installation

```bash
mix setup
```

This runs `deps.get`, creates and migrates the database, seeds demo data, and builds assets.

### Start the application

```bash
iex -S mix phx.server
```

Access the application at <http://localhost:4000/>

## Seed data

The seed file (`priv/repo/seeds.exs`) queues commands for backend processing:

- 1 ledger instance (`ledger:1`)
- 5 account commands (EUR/USD assets, liability, equity)
- 14 transaction commands including 3 that intentionally fail (overdraft violations, unbalanced entries)

Commands are processed asynchronously by Oban workers which create accounts, entries, balances, and balance history.

To re-seed on an existing database:

```bash
mix run priv/repo/seeds.exs
```

To reset everything from scratch:

```bash
mix ecto.reset
```
