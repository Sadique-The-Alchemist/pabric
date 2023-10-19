defmodule Pabric.Sheet.Acrylic do
  defstruct [:current_cell, :sheet, :name]
  use GenServer
  require Logger
  alias :ets, as: PabricTerm
  alias Pabric.Sheet.Cell
  alias Pabric.Sheet.Leaf
  @initial_cell "A1"
  def init({name, size}) do
    %{keys: keys} = sheet = quick_sheet(name, size)
    PabricTerm.new(name, [:set, :protected, :named_table])
    iniitialize_sheet(name, keys)
    [{_key, initial_cell}] = PabricTerm.lookup(name, @initial_cell)
    # IO.inspect(keys, label: "Started with keys")
    Logger.info("Started acrylik with keys #{keys}")
    {:ok, %__MODULE__{current_cell: initial_cell, name: name, sheet: sheet}}
  end

  def render_sheet() do
    GenServer.call(__MODULE__, :sheet)
  end

  def current_cell() do
    GenServer.call(__MODULE__, :current_cell)
  end

  def render(name, size) do
    GenServer.start_link(__MODULE__, {name, size}, name: __MODULE__)
  end

  def focus(key) do
    GenServer.call(__MODULE__, {:focus, key})
  end

  def write(key, value) do
    GenServer.call(__MODULE__, {:write, key, value})
  end

  def handle_call(
        {:write, key, value},
        _from,
        %__MODULE__{current_cell: current_cell, name: name} = state
      ) do
    cell = %{current_cell | value: value}
    PabricTerm.update_element(name, key, {2, cell})
    {:reply, cell, %{state | current_cell: cell}}
  end

  def handle_call(
        {:focus, key},
        _from,
        %__MODULE__{current_cell: _current_cell, name: name} = state
      ) do
    [{^key, cell}] = PabricTerm.lookup(name, key)
    {:reply, cell, %{state | current_cell: cell}}
  end

  def handle_call(:sheet, _from, %__MODULE__{current_cell: _current_cell, sheet: sheet} = state) do
    {:reply, sheet, state}
  end

  def handle_call(:current_cell, _from, %__MODULE__{current_cell: current_cell} = state) do
    {:reply, current_cell, state}
  end

  defp quick_sheet(name, {x, y} = size) do
    keys =
      1..y
      |> Enum.map(fn y ->
        1..x
        |> Enum.map(fn x ->
          "#{Integer.to_string(x + 9, 36)}#{y}"
        end)
      end)

    %Leaf{name: name, size: size, keys: keys}
  end

  defp iniitialize_sheet(name, keys) do
    keys
    |> List.flatten()
    |> Enum.map(fn x -> PabricTerm.insert_new(name, {x, %Cell{key: x, value: ""}}) end)
  end
end
