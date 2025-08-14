defmodule ModernResumeWeb.FormComponents.FormField do
  use Phoenix.Component

  import ModernResumeWeb.FormComponents.Error

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  slot :label, required: true
  slot :inner_block, required: true

  def form_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns =
      assign_new(assigns, :errors, fn ->
        Enum.map(errors, &translate_error(&1))
      end)

    ~H"""
    <div class="flex flex-col gap-1">
      <label class="flex flex-col gap-1">
        <span class="block text-sm font-semibold text-secondary">{render_slot(@label)}</span>
        {render_slot(@inner_block)}
      </label>
      <.error :for={err <- @errors}>{err}</.error>
    </div>
    """
  end
end
