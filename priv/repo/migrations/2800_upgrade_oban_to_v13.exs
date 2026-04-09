defmodule DoubleEntryLedger.Repo.Migrations.UpgradeObanToV13 do
  use Ecto.Migration

  @schema_prefix Application.compile_env(:double_entry_ledger, Oban)[:prefix]

  def up do
    Oban.Migration.up(version: 13, prefix: @schema_prefix, create_schema: false)
  end

  def down do
    Oban.Migration.down(version: 12, prefix: @schema_prefix)
  end
end
