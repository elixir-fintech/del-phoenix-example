defmodule DoubleEntryLedger.Repo.Migrations.UpgradeObanToV14 do
  use Ecto.Migration

  @schema_prefix Application.compile_env(:double_entry_ledger, Oban)[:prefix]

  def up do
    Oban.Migration.up(version: 14, prefix: @schema_prefix, create_schema: false)
  end

  def down do
    Oban.Migration.down(version: 13, prefix: @schema_prefix)
  end
end
