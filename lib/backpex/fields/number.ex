defmodule Backpex.Fields.Number do
  @moduledoc """
  A field for handling a number value.

  ## Options

  * `:placeholder` - Optional placeholder value.
  * `:debounce` - Optional integer timeout value (in milliseconds), or "blur".
  * `:throttle` - Optional integer timeout value (in milliseconds).
  """
  use BackpexWeb, :field

  import Ecto.Query

  @impl Backpex.Field
  def render_value(assigns) do
    ~H"""
    <p class={@live_action in [:index, :resource_action] && "truncate"}>
      <%= HTML.pretty_value(@value) %>
    </p>
    """
  end

  @impl Backpex.Field
  def render_form(assigns) do
    ~H"""
    <div>
      <Layout.field_container>
        <:label align={Backpex.Field.align_label(@field_options, assigns)}>
          <Layout.input_label text={@field_options[:label]} />
        </:label>
        <BackpexForm.field_input type="text" form={@form} field_name={@name} field_options={@field_options} />
      </Layout.field_container>
    </div>
    """
  end

  @impl Backpex.Field
  def render_index_form(assigns) do
    assigns =
      assigns
      |> assign(:input_id, "index_input_#{assigns.item.id}_#{assigns.name}")
      |> assign_new(:valid, fn -> true end)

    ~H"""
    <div>
      <.form
        :let={f}
        for={%{}}
        as={:index_form}
        class="relative"
        phx-change="update-field"
        phx-submit="update-field"
        phx-target={@myself}
      >
        <%= Phoenix.HTML.Form.text_input(
          f,
          :index_input,
          class: ["input input-sm", if(@valid, do: "hover:input-bordered", else: "input-error")],
          value: @value,
          phx_debounce: "100",
          readonly: @readonly,
          id: @input_id
        ) %>
      </.form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("update-field", %{"index_form" => %{"index_input" => value}}, socket) do
    Backpex.Field.handle_index_editable(socket, %{} |> Map.put(socket.assigns.name, value))
  end

  @impl Backpex.Field
  def search_condition(schema_name, field_name, search_string) do
    dynamic(
      [{^schema_name, schema_name}],
      ilike(fragment("CAST(? AS TEXT)", schema_name |> field(^field_name)), ^search_string)
    )
  end
end
