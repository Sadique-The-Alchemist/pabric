defmodule Pabric.Sheet.Cell do
  defstruct [:key, :value, :errors]

  def new(key) do
    %__MODULE__{key: key, value: "", errors: []}
  end
end
