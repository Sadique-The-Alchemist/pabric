defmodule PabricWeb.SheetComonent do
  use Phoenix.Component

  import PabricWeb.CoreComponents
  alias Phoenix.LiveView.JS

  def new(assigns) do
    ~H"""
    <.form for={@sheet} phx-submit={@submit}>
      <.input id="name" type="text" name="name" value="" field={@sheet[:name]} />
      <.input id="x" type="text" name="sizex" value="" field={@sheet[:sizex]} />
      <.input id="y" type="text" name="sizey" value="" field={@sheet[:sizey]} />
      <button>Create</button>
    </.form>
    """
  end

  def cell(assigns) do
    ~H"""
    <.form for={@cell} phx-submit={@submit}>
      <.cell_input
        id={@cell["key"]}
        type="text"
        name={@cell["key"]}
        value={@cell["value"]}
        field={@cell["value"]}
        errors={@cell["errors"]}
        phx-click={JS.push("focus", value: %{id: @cell["key"]})}
        phx-change={JS.push("write", value: %{id: @cell["key"]})}
      />
      <.input id="key" type="hidden" name="cell_key" value={@cell["key"]} />
    </.form>
    """
  end

  attr :id, :string, required: true
  attr :keys, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :cell, :any, required: true, doc: "The function for generating cell"

  def spread(assigns) do
    ~H"""
    <div class="overflow-y-auto h-40 px-1 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] mt-1 sm:w-full">
        <tbody>
          <tr :for={row <- @keys} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td :for={key <- row}>
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
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end
end
