defimpl Phoenix.Param, for: DoubleEntryLedger.Account do
  def to_param(%{address: address}), do: address
end
