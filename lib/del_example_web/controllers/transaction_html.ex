defmodule DelExampleWeb.TransactionHTML do
  use DelExampleWeb, :html

  embed_templates "transaction_html/*"

  def extract_trx({trx, _, _}), do: trx
end
