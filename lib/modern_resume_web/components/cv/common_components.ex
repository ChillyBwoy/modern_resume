defmodule ModernResumeWeb.CV.CommonComponents do
  use Phoenix.Component

  import ModernResumeWeb.CoreComponents

  alias Phoenix.LiveView.JS

  attr :id, :string, required: true

  slot :item, required: true do
    attr :icon, :string

    attr :variant, :atom,
      values: [:default, :primary, :secondary, :success, :danger, :warning, :info]

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
        class="hidden absolute left-0 top-8 w-48 bg-white rounded-lg shadow-lg border border-gray-200 z-10"
      >
        <div class="flex flex-col">
          <button
            :for={item <- @item}
            class={[
              "flex w-full cursor-pointer items-center gap-2 rounded-md px-4 py-2 text-left text-sm",
              item[:variant] == :primary ||
                (item[:variant] == nil &&
                   "text-primary fill-primary hover:bg-primary hover:fill-white hover:text-white"),
              item[:variant] == :secondary &&
                "text-secondary fill-secondary hover:bg-secondary hover:fill-white hover:text-white",
              item[:variant] == :success &&
                "text-success fill-success hover:bg-success hover:fill-white hover:text-white",
              item[:variant] == :warning &&
                "text-warning fill-warning hover:bg-warning hover:fill-white hover:text-white",
              item[:variant] == :danger &&
                "text-danger fill-danger hover:bg-danger hover:fill-white hover:text-white",
              item[:variant] == :info &&
                "text-info fill-info hover:bg-info hover:fill-white hover:text-white"
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
end
