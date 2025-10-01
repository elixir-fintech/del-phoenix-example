defimpl Phoenix.Param, for: DoubleEntryLedger.Instance do
  def to_param(%{address: address}), do: address
end
