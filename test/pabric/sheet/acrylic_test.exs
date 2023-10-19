defmodule Pabric.Sheet.AcrylicTest do
  use ExUnit.Case
  alias Pabric.Sheet.Acrylic

  setup do
    name = :konna
    size = {10, 10}
    Acrylic.render(name, size)
    {:ok, %{name: name, size: size}}
  end

  describe "focus/1" do
    test "initialise data for genserver" do
      key = "A1"
      cell = Acrylic.focus(key)
      assert cell.key == key
    end
  end

  describe "write" do
    test "update value of the cell" do
      key = "A1"
      value = "Name"
      cell = Acrylic.write(key, value)
      assert cell.key == key
      assert cell.value == value
    end
  end
end
