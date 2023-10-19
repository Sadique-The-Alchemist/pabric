defmodule Pabric.Sheet.Cell do
  defstruct [:key, :value]

  def new(key) do
    %__MODULE__{key: key, value: ""}
  end
end
