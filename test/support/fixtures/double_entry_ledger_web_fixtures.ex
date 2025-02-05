defmodule DelExample.DoubleEntryLedgerWebFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DelExample.DoubleEntryLedgerWeb` context.
  """

  @doc """
  Generate a instance.
  """
  def instance_fixture(attrs \\ %{}) do
    {:ok, instance} =
      attrs
      |> Enum.into(%{

      })
      |> DelExample.DoubleEntryLedgerWeb.create_instance()

    instance
  end
end
