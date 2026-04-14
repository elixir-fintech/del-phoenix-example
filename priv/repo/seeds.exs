# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# The seed creates an instance directly, then queues all account and
# transaction commands for backend processing. The Oban workers pick
# them up and create accounts, entries, balances, and history.

alias DoubleEntryLedger.Stores.InstanceStore
alias DoubleEntryLedger.Apis.CommandApi

# ---------------------------------------------------------------------------
# Instance (created directly - not a command)
# ---------------------------------------------------------------------------

{:ok, instance} =
  case InstanceStore.get_by_address("ledger:1") do
    nil ->
      InstanceStore.create(%{address: "ledger:1", description: "Demo ledger instance"})

    existing ->
      {:ok, existing}
  end

IO.puts("Instance: #{instance.address} (#{instance.id})")

# ---------------------------------------------------------------------------
# Account commands
# ---------------------------------------------------------------------------

account_commands = [
  %{
    "name" => "EUR cash account",
    "address" => "asset:1:eur",
    "type" => "asset",
    "currency" => "EUR",
    "description" => "Main euro cash account"
  },
  %{
    "name" => "USD cash account",
    "address" => "asset:1:usd",
    "type" => "asset",
    "currency" => "USD",
    "description" => "Main US dollar cash account"
  },
  %{
    "name" => "EUR overdraft account",
    "address" => "asset:with:overdraft",
    "type" => "asset",
    "currency" => "EUR",
    "description" => "Euro account that allows overdraft",
    "negative_limit" => 2000
  },
  %{
    "name" => "USD liability account",
    "address" => "liability:1:usd",
    "type" => "liability",
    "currency" => "USD",
    "description" => "US dollar liability account"
  },
  %{
    "name" => "EUR equity account",
    "address" => "equity:1:eur",
    "type" => "equity",
    "currency" => "EUR",
    "description" => "Euro equity account"
  }
]

for {payload, idx} <- Enum.with_index(account_commands, 1) do
  cmd = %{
    "instance_address" => "ledger:1",
    "action" => "create_account",
    "source" => "seed",
    "source_idempk" => "seed-account-#{idx}",
    "payload" => payload
  }

  case CommandApi.create_from_params(cmd) do
    {:ok, command} ->
      IO.puts("  Queued: create_account #{payload["address"]} (#{command.id})")

    {:error, reason} ->
      IO.puts("  Failed: create_account #{payload["address"]} - #{inspect(reason)}")
  end
end

# ---------------------------------------------------------------------------
# Transaction commands
# ---------------------------------------------------------------------------

transaction_commands = [
  # 1. Posted: EUR transfer from cash to overdraft
  %{
    "idempk" => "seed-trx-01",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:1:eur", "amount" => "1500", "currency" => "EUR"},
      %{"account_address" => "asset:with:overdraft", "amount" => "-1500", "currency" => "EUR"}
    ]
  },
  # 2. Posted: EUR transfer back
  %{
    "idempk" => "seed-trx-02",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:with:overdraft", "amount" => "1845", "currency" => "EUR"},
      %{"account_address" => "equity:1:eur", "amount" => "1845", "currency" => "EUR"}
    ]
  },
  # 3. Posted: USD transaction
  %{
    "idempk" => "seed-trx-03",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:1:usd", "amount" => "4567", "currency" => "USD"},
      %{"account_address" => "liability:1:usd", "amount" => "4567", "currency" => "USD"}
    ]
  },
  # 4. Pending: USD transaction awaiting approval
  %{
    "idempk" => "seed-trx-04",
    "status" => "pending",
    "entries" => [
      %{"account_address" => "asset:1:usd", "amount" => "1000", "currency" => "USD"},
      %{"account_address" => "liability:1:usd", "amount" => "1000", "currency" => "USD"}
    ]
  },
  # 5. Posted: small EUR payment
  %{
    "idempk" => "seed-trx-05",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:1:eur", "amount" => "250", "currency" => "EUR"},
      %{"account_address" => "equity:1:eur", "amount" => "250", "currency" => "EUR"}
    ]
  },
  # 6. Posted: USD refund
  %{
    "idempk" => "seed-trx-06",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "liability:1:usd", "amount" => "-800", "currency" => "USD"},
      %{"account_address" => "asset:1:usd", "amount" => "-800", "currency" => "USD"}
    ]
  },
  # 7. Posted: EUR internal transfer
  %{
    "idempk" => "seed-trx-07",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:1:eur", "amount" => "-300", "currency" => "EUR"},
      %{"account_address" => "asset:with:overdraft", "amount" => "300", "currency" => "EUR"}
    ]
  },
  # 8. Pending: large EUR settlement
  %{
    "idempk" => "seed-trx-08",
    "status" => "pending",
    "entries" => [
      %{"account_address" => "asset:1:eur", "amount" => "5000", "currency" => "EUR"},
      %{"account_address" => "equity:1:eur", "amount" => "5000", "currency" => "EUR"}
    ]
  },
  # 9. Posted: USD fee collection
  %{
    "idempk" => "seed-trx-09",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:1:usd", "amount" => "150", "currency" => "USD"},
      %{"account_address" => "liability:1:usd", "amount" => "150", "currency" => "USD"}
    ]
  },
  # 10. Posted: EUR overdraft repayment
  %{
    "idempk" => "seed-trx-10",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:with:overdraft", "amount" => "-500", "currency" => "EUR"},
      %{"account_address" => "asset:1:eur", "amount" => "500", "currency" => "EUR"}
    ]
  },
  # 11. WILL FAIL - overdraft: drains EUR cash below zero (no negative_limit on asset:1:eur)
  %{
    "idempk" => "seed-trx-11-overdraft-cash",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:1:eur", "amount" => "-999999", "currency" => "EUR"},
      %{"account_address" => "equity:1:eur", "amount" => "999999", "currency" => "EUR"}
    ]
  },
  # 12. WILL FAIL - overdraft: exceeds negative_limit on overdraft account
  %{
    "idempk" => "seed-trx-12-overdraft-limit",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:with:overdraft", "amount" => "-500000", "currency" => "EUR"},
      %{"account_address" => "asset:1:eur", "amount" => "500000", "currency" => "EUR"}
    ]
  },
  # 13. WILL FAIL - unbalanced: debit and credit do not match
  %{
    "idempk" => "seed-trx-13-unbalanced",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:1:usd", "amount" => "1000", "currency" => "USD"},
      %{"account_address" => "liability:1:usd", "amount" => "500", "currency" => "USD"}
    ]
  },
  # 14. Posted: final USD cleanup
  %{
    "idempk" => "seed-trx-14",
    "status" => "posted",
    "entries" => [
      %{"account_address" => "asset:1:usd", "amount" => "200", "currency" => "USD"},
      %{"account_address" => "liability:1:usd", "amount" => "200", "currency" => "USD"}
    ]
  }
]

for trx <- transaction_commands do
  {idempk, payload} = Map.pop!(trx, "idempk")

  cmd = %{
    "instance_address" => "ledger:1",
    "action" => "create_transaction",
    "source" => "seed",
    "source_idempk" => idempk,
    "payload" => payload
  }

  case CommandApi.create_from_params(cmd) do
    {:ok, command} ->
      IO.puts("  Queued: #{idempk} (#{command.id})")

    {:error, reason} ->
      IO.puts("  Failed: #{idempk} - #{inspect(reason)}")
  end
end

IO.puts("\nSeed complete. Commands queued for backend processing.")
