defmodule DelExampleWeb.ViewHelpers do
  @moduledoc """
  View helpers for the application.
  """

  def format_datetime(nil), do: ""

  def format_datetime(datetime) do
    Calendar.strftime(datetime, "%c")
  end

  def status_badge(status) do
    case status do
      :posted -> "badge badge-success"
      :processed -> "badge badge-success"
      :pending -> "badge badge-warning"
      :failed -> "badge badge-error"
      :archived -> "badge badge-error"
      :dead_letter -> "badge badge-neutral"
      _ -> "badge badge-ghost"
    end
  end

  def to_money(value, currency) do
    DoubleEntryLedger.Utils.Currency.to_money(value, currency)
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

  def event_source_format(%{command_map: %{source_idempk: source_idempk} = command_map}) do
    [
      "src:\u00A0#{command_map.source}",
      "source_idempk:\u00A0#{source_idempk}",
      if command_map.update_idempk do
        "update_idempk:\u00A0#{command_map.update_idempk}"
      end
    ]
    |> Enum.reject(&(&1 == "" || is_nil(&1)))
    |> Enum.join(", ")
  end

  def event_source_format(%{command_map: %{source: source}}), do: "src: #{source}"

  def assoc_loaded_and_present?(%Ecto.Association.NotLoaded{}), do: false
  def assoc_loaded_and_present?(nil), do: false
  def assoc_loaded_and_present?(_), do: true
end
