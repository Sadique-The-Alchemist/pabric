defmodule PabricWeb.SheetComonent do
  use Phoenix.Component

  import PabricWeb.CoreComponents
  alias Phoenix.LiveView.JS

  def new(assigns) do
    ~H"""
    <.form for={@sheet} phx-submit={@submit}>
      <div class="relative">
        <div class="flex space-x-3 my-3">
          <.input id="name" type="text" name="name" value="" label="Name" field={@sheet[:name]} />
          <.input
            id="columns"
            type="text"
            name="columns"
            value=""
            label="Columns"
            field={@sheet[:columns]}
          />
          <.input
            id="headers"
            type="text"
            name="headers"
            value=""
            label="Headers"
            field={@sheet[:headers]}
          />
        </div>
        <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 h-1/2 rounded">
          Create
        </button>
      </div>
    </.form>
    """
  end

  def cell(assigns) do
    ~H"""
    <.form for={@cell} phx-submit={@submit} class="w-full">
      <.cell_input
        id={@cell["key"]}
        type="text"
        name={@cell["key"]}
        value={@cell["value"]}
        field={@cell["value"]}
        errors={@cell["errors"]}
        phx-click={JS.push("focus", value: %{id: @cell["key"]})}
        phx-change={JS.push("write", value: %{id: @cell["key"]})}
        class="w-fit"
      />
      <.input id="key" type="hidden" name="cell_key" value={@cell["key"]} />
    </.form>
    """
  end

  attr :id, :string, required: true
  attr :keys, :list, required: true
  attr :headers, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :cell, :any, required: true, doc: "The function for generating cell"

  def spread(assigns) do
    ~H"""
    <div class="overflow-scroll snap-both h-1/2 px-1 sm:px-0">
      <table class="w-[40rem] mt-1 sm:w-full border border-zinc-500">
        <thead class="text-sm font-semibold text-center leading-6 text-zinc-800">
          <tr>
            <th :for={header <- @headers} class="p-0 pr-6 pb-4 font-normal border border-zinc-500">
              <%= header %>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr :for={row <- @keys} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td :for={key <- row} class="border border-zinc-500">
              <div>
                <.cell cell={@cell && @cell.(key)} submit={JS.push("write", value: %{id: key})} />
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
              multiple pattern placeholder readonly required rows size step)

  attr :id, :any, default: nil
  attr :name, :any
  attr :value, :any
  attr :type, :string, default: "text"

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []

  def cell_input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "block w-full text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-50 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end
end
