defmodule DelExampleWeb.EventHTML do
  use DelExampleWeb, :html

  embed_templates "event_html/*"

  def event_form(assigns)
end
