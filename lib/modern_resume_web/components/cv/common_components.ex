defmodule ModernResumeWeb.CV.CommonComponents do
  use Phoenix.Component

  import ModernResumeWeb.CoreComponents

  alias Phoenix.LiveView.JS

  attr :id, :string, required: true

  slot :item, required: true do
    attr :icon, :string

    attr :variant, :atom,
      values: [:none, :primary, :secondary, :success, :danger, :warning, :info]

    attr :action, JS
  end

  def dropdown_menu(assigns) do
    ~H"""
    <div
      id={"dropdown-#{@id}"}
      class="inline-flex h-max w-max relative"
      phx-window-keydown={hide("#dropdown-#{@id}-body")}
      phx-key="escape"
      phx-click-away={hide("#dropdown-#{@id}-body")}
    >
      <button
        type="button"
        phx-click={toggle("#dropdown-#{@id}-body")}
        class="hover:bg-secondary-light rounded-full text-secondary size-8 cursor-pointer"
      >
        <.icon name="hero-ellipsis-vertical" class="size-6" />
      </button>
      <div
        id={"dropdown-#{@id}-body"}
        class="hidden absolute left-0 top-8 w-48 bg-white shadow-lg border border-gray-200 z-10 rounded-md"
      >
        <div class="flex flex-col">
          <button
            :for={item <- @item}
            class={[
              "flex w-full cursor-pointer items-center gap-2 px-4 py-2 text-left text-sm first:rounded-t-md last:rounded-b-md",
              dropdown_menu_item_class(item[:variant])
            ]}
            phx-click={item[:action]}
          >
            <span class="flex items-center gap-2">
              <.icon name={item[:icon]} class="size-4" />
              {render_slot(item)}
            </span>
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp dropdown_menu_item_class(:primary),
    do: "text-primary fill-primary hover:text-primary-dark fill:text-primary-dark"

  defp dropdown_menu_item_class(:secondary),
    do: "text-secondary fill-secondary hover:text-secondary-dark fill:text-secondary-dark"

  defp dropdown_menu_item_class(:success),
    do: "text-success fill-success hover:text-success-dark fill:text-success-dark"

  defp dropdown_menu_item_class(:warning),
    do: "text-warning fill-warning hover:text-warning-dark fill:text-warning-dark"

  defp dropdown_menu_item_class(:danger),
    do: "text-danger fill-danger hover:text-danger-dark fill:text-danger-dark"

  defp dropdown_menu_item_class(:info),
    do: "text-info fill-info hover:text-info-dark fill:text-info-dark"

  defp dropdown_menu_item_class(_),
    do: ""
end
