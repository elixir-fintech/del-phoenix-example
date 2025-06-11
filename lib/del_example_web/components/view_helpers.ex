defmodule DelExampleWeb.ViewHelpers do
  @moduledoc """
  View helpers for the application.
  """

  def format_datetime(nil), do: ""

  def format_datetime(datetime) do
    Calendar.strftime(datetime, "%c")
  end

  def status_color(status) do
    case status do
      :posted -> "text-green-600 font-bold"
      :processed -> "text-green-600 font-bold"
      :pending -> "text-yellow-600"
      :failed -> "text-red-600 font-bold"
      :archived -> "text-red-600 font-bold"
      _ -> "text-gray-600"
    end
  end

  def to_money(value, currency) do
    DoubleEntryLedger.Currency.to_money(value, currency)
  end

  def balance_format(balance, currency) do
    Enum.join(
      [
        "#{to_money(balance.amount, currency)}",
        "d:\u00A0#{to_money(balance.debit, currency)}",
        "c:\u00A0#{to_money(balance.credit, currency)}"
      ],
      ", "
    )
  end

  def event_source_format(event) do
    [
      "src:\u00A0#{event.source}",
      "source_idempk:\u00A0#{event.source_idempk}",
      "update_idempk:\u00A0#{event.update_idempk}"
    ]
    |> Enum.join(", ")
  end
end
