defmodule ModernResumeWeb.FormComponents.FormField do
  use Phoenix.Component

  import ModernResumeWeb.FormComponents.Error

  attr :id, :any, default: nil

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :position, :atom, values: [:top, :right, :left], default: :top
  attr :rest, :global

  slot :label, required: true
  slot :inner_block, required: true

  def form_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns =
      assigns
      |> assign(id: assigns.id || assigns.field.id)
      |> assign_new(:errors, fn ->
        Enum.map(errors, &translate_error(&1))
      end)

    ~H"""
    <div class="flex flex-col gap-1" {@rest}>
      <.form_field_content position={@position}>
        <:label>{render_slot(@label)}</:label>
        {render_slot(@inner_block)}
      </.form_field_content>
      <div :if={@errors != []} class="flex flex-col gap-1">
        <.error :for={err <- @errors} class="text-xs" data-testid="form-field-error">{err}</.error>
      </div>
    </div>
    """
  end

  attr :position, :atom, values: [:top, :right, :left], required: true

  slot :label, required: true
  slot :inner_block, required: true

  defp form_field_content(%{position: :top} = assigns) do
    ~H"""
    <label class="flex flex-col gap-1">
      <span
        class="block text-sm font-semibold text-secondary cursor-pointer"
        data-testid="form-field-label"
      >
        {render_slot(@label)}
      </span>
      {render_slot(@inner_block)}
    </label>
    """
  end

  defp form_field_content(%{position: :right} = assigns) do
    ~H"""
    <label class="flex items-center gap-1">
      <span
        class="block text-sm font-semibold text-secondary cursor-pointer"
        data-testid="form-field-label"
      >
        {render_slot(@label)}
      </span>
      {render_slot(@inner_block)}
    </label>
    """
  end

  defp form_field_content(%{position: :left} = assigns) do
    ~H"""
    <label class="flex items-center gap-1">
      {render_slot(@inner_block)}
      <span
        class="block text-sm font-semibold text-secondary cursor-pointer"
        data-testid="form-field-label"
      >
        {render_slot(@label)}
      </span>
    </label>
    """
  end
end
