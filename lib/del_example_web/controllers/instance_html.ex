defmodule DelExampleWeb.InstanceHTML do
  use DelExampleWeb, :html

  embed_templates "instance_html/*"

  @doc """
  Renders a instance form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def instance_form(assigns)
end
