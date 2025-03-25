defmodule DelExampleWeb.ViewHelpers do
  @moduledoc """
  View helpers for the application.
  """
  def format_datetime(datetime) do
    Calendar.strftime(datetime, "%c")
  end

  def status_color(status) do
    case status do
      :posted -> "text-green-600 font-bold"
      :processed -> "text-green-600 font-bold"
      :pending -> "text-yellow-600"
      :failed -> "text-red-600 font-bold"
      _ -> "text-gray-600"
    end
  end

  def to_money(value, currency) do
    Money.new(value, currency)
  end

  def balance_format(balance, currency) do
    Enum.join(
      [
        "#{to_money(balance.amount, currency)}",
        "d:\u00A0#{to_money(balance.debit, currency)}",
        "c:\u00A0#{to_money(balance.credit, currency)}"
      ],
      ", ")
  end

  def format_money(value) do
    "#{value.amount/100} #{value.currency}"
  end
end
