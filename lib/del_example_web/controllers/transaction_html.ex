defmodule DelExampleWeb.TransactionHTML do
  use DelExampleWeb, :html
  import DelExampleWeb.ViewHelpers

  embed_templates "transaction_html/*"

  def extract_trx({trx, _, _, _}), do: trx
end
