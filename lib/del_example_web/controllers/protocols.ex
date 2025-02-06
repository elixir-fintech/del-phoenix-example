defimpl Phoenix.HTML.Safe, for: DoubleEntryLedger.Balance do
  def to_iodata(balance) do
    "amount: #{balance.amount}, debit: #{balance.debit}, credit: #{balance.credit}"
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
