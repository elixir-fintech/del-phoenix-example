defmodule DelExampleWeb.EventApiJSON do
  def show(%{event: event, related_events: related_events}) do
    %{event: event, related_events: related_events}
  end

  def created(%{event: event}) do
    %{id: event.id}
  end
end
