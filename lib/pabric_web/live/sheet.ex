defmodule PabricWeb.SheetLive do
  use PabricWeb, :live_view
  alias Pabric.Sheet.Acrylic

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@cell} phx-submit="update_cell">
        <.input id="cell" type="text" name="cell_value" field={@cell[:value]} />
        <.input id="key" type="hidden" name="cell_key" field={@cell[:key]} />
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    current_cell = Acrylic.current_cell()
    {:ok, assign(socket, :cell, current_cell)}
  end

  def handle_event("update_cell", %{"key" => key, "value" => value}, socket) do
    Acrylic.write(key, value)
    {:noreply, socket}
  end
end
