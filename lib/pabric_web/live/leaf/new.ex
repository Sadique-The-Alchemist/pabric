defmodule PabricWeb.Leaf.NewLive do
  use PabricWeb, :live_view
  alias Pabric.Sheet.Acrylic

  def render(assigns) do
    ~H"""
    <div></div>
    """
  end

  def mount(_params, _session, socket) do
    sheet = %{"name" => "", "sizex" => "", "sizey" => ""}
    socket = assign(socket, :sheet, sheet)
    {:ok, socket}
  end

  def handle_event("create", %{"name" => name, "sizex" => x, "sizey" => y}, socket) do
    name = String.to_atom(name)
    size = {String.to_integer(x), String.to_integer(y)}
    Acrylic.render(name, size)
    socket = socket |> assign(name: name, size: size)
    {:noreply, push_patch(socket, to: ~p"/sheet")}
  end
end
