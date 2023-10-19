defmodule PabricWeb.LeafLive do
  use PabricWeb, :live_view

  import PabricWeb.SheetComonent
  alias Pabric.Sheet.Acrylic
  alias Pabric.Sheet.Cell

  def render(assigns) do
    ~H"""
    <div>
      <.new sheet={@sheet} submit="create" />
      <%= if @keys do %>
        <.spread id="pabric" keys={@keys} cell={@cell} />
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    sheet = %{"name" => "", "sizex" => "", "sizey" => ""}

    socket = socket |> assign(sheet: sheet, keys: nil)
    {:ok, socket}
  end

  def handle_event("create", %{"name" => name, "sizex" => x, "sizey" => y}, socket) do
    name = String.to_atom(name)
    size = {String.to_integer(x), String.to_integer(y)}
    Acrylic.render(name, size)
    %{keys: keys} = Acrylic.render_sheet()
    row_id = fn row -> make_row_id(row) end
    cell = fn key -> align_cell(key) end
    socket = socket |> assign(keys: keys, name: name, size: size, row_id: row_id, cell: cell)
    {:noreply, socket}
  end

  def handle_event("write", %{"cell_key" => key, "cell_value" => value}, socket) do
    Acrylic.write(key, value)

    {:noreply, socket}
  end

  def handle_event("write", %{"_target" => [key]} = params, socket) do
    value = params[key]
    Acrylic.write(key, value)
    {:noreply, socket}
  end

  def handle_event("focus", %{"id" => key}, socket) do
    Acrylic.focus(key)
    {:noreply, socket}
  end

  defp make_row_id([first | _]) do
    String.slice(first, 1..2)
  end

  defp align_cell(key) do
    key |> Cell.new() |> Map.from_struct() |> stringify()
  end

  defp stringify(map) do
    for {k, v} <- map, into: %{}, do: {Atom.to_string(k), v}
  end
end
