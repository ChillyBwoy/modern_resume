defmodule ModernResumeWeb.CoreComponents do
  use Phoenix.Component
  use Gettext, backend: ModernResumeWeb.Gettext

  import ModernUI.Components.Icon

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <.link navigate={@navigate} class="flex items-center gap-1">
      <.icon name="mdi-chevron-left" />
      <span class="text-xs font-semibold">{render_slot(@inner_block)}</span>
    </.link>
    """
  end

  @doc """
  Renders an auth form.
  """
  attr :for, :any, required: true, doc: "the data structure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="flex flex-col gap-6">
        <div class="flex flex-col gap-2">
          {render_slot(@inner_block, f)}
        </div>
        <div :for={action <- @actions} class="flex flex-col gap-2">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end
end
