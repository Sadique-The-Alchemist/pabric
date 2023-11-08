defmodule Pabric.Sheet.Acrylic do
  defstruct [:current_cell, :sheet, :name]
  use GenServer
  require Logger
  alias :ets, as: PabricTerm
  alias Pabric.Sheet.Cell
  alias Pabric.Sheet.Leaf

  def init({name, columns, headers}) do
    %{keys: keys} = sheet = quick_sheet(name, columns, headers)
    PabricTerm.new(name, [:set, :protected, :named_table])
    iniitialize_sheet(name, keys)
    [{_key, initial_cell}] = PabricTerm.lookup(name, keys |> hd() |> hd())
    Logger.info("Started acrylik with keys #{keys}")
    {:ok, %__MODULE__{current_cell: initial_cell, name: name, sheet: sheet}}
  end

  def render_sheet() do
    GenServer.call(__MODULE__, :sheet)
  end

  def spread_sheet() do
    GenServer.call(__MODULE__, :spread_sheet)
  end

  def current_cell() do
    GenServer.call(__MODULE__, :current_cell)
  end

  def render(name, columns, headers) do
    GenServer.start_link(__MODULE__, {name, columns, headers}, name: __MODULE__)
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
    IO.inspect(cell)
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

  def handle_call(
        :spread_sheet,
        _from,
        %__MODULE__{current_cell: _current_cell, sheet: sheet} = state
      ) do
    res = PabricTerm.match_object(sheet.name, {:"$1", :"$2"})
    IO.inspect(res)
    {:reply, %{sheet | sheet: res}, state}
  end

  def handle_call(:current_cell, _from, %__MODULE__{current_cell: current_cell} = state) do
    {:reply, current_cell, state}
  end

  defp quick_sheet(name, columns, headers) do
    keys =
      1..10
      |> Enum.map(fn y ->
        headers
        |> Enum.map(fn header ->
          "#{header}#{y}"
        end)
      end)

    %Leaf{name: name, columns: columns, keys: keys, headers: headers}
  end

  defp iniitialize_sheet(name, keys) do
    keys
    |> List.flatten()
    |> Enum.map(fn x -> PabricTerm.insert_new(name, {x, %Cell{key: x, value: ""}}) end)
  end
end
