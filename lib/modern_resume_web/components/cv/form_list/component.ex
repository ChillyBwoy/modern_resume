defmodule ModernResumeWeb.CV.FormList.Component do
  use ModernResumeWeb, :live_component
  use Phoenix.Component

  import ModernResumeWeb.CVComponents

  alias ModernResumeWeb.CV.FormList.EntityFormList

  defp notify(socket) do
    case Map.fetch(socket.assigns, :on_change) do
      {:ok, reason} ->
        send(self(), reason)
        socket

      _err ->
        socket
    end
  end

  @impl true
  def update(assigns, socket) do
    controller = assigns.controller
    state = assigns.state

    {:ok,
     socket
     |> assign(assigns)
     |> assign(items: EntityFormList.create(state, controller))
     |> assign(form: nil)}
  end

  @impl true
  def handle_event("show_form", _, socket) do
    controller = socket.assigns.controller
    state = socket.assigns.state

    changeset = controller.create_changeset(state)
    {:noreply, socket |> assign(form: to_form(changeset))}
  end

  @impl true
  def handle_event("hide_form", _, socket) do
    {:noreply, socket |> assign(form: nil)}
  end

  @impl true
  def handle_event("create", params, socket) do
    controller = socket.assigns.controller
    state = socket.assigns.state

    with {:ok, _} <- controller.create_entity(params, state) do
      {:noreply,
       socket
       |> assign(form: nil)
       |> assign(items: EntityFormList.create(state, controller))
       |> notify()}
    else
      {:error, changeset} ->
        {:noreply, socket |> assign(form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("update", params, socket) do
    controller = socket.assigns.controller
    state = socket.assigns.state

    with {id, params} <- Map.pop(params, "id"),
         entity <- Enum.find(controller.get_list(state), &(&1.id == id)),
         {:ok, _} <- controller.update_entity(entity, params) do
      {:noreply,
       socket
       |> assign(items: EntityFormList.create(state, controller))
       |> notify()}
    else
      {:nochanges, _} ->
        {:noreply, socket}

      {:error, changeset} ->
        items = EntityFormList.update(socket.assigns.items, params.id, changeset)
        {:noreply, socket |> assign(items: items)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    controller = socket.assigns.controller
    state = socket.assigns.state

    with entity <- Enum.find(controller.get_list(state), &(&1.id == id)),
         {:ok, _} <- controller.delete_entity(entity) do
      {:noreply,
       socket
       |> assign(items: EntityFormList.create(state, controller))
       |> notify()}
    end
  end

  @impl true
  def handle_event("sort", params, socket) do
    socket.assigns.controller.sort_list(params)
    {:noreply, socket |> notify()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="flex flex-col gap-2">
      <ol
        id={"#{@id}-list"}
        class="flex flex-col gap-2"
        data-sort-action={JS.push("sort", target: @myself)}
        phx-hook="Sortable"
      >
        <li :for={item <- @items} class="relative" data-id={item.entity.id}>
          <div class="group">
            <.cv_item>
              {@form_module.render_form(%{
                id: "#{item.entity.id}-entity",
                form: item.form,
                on_submit: JS.push("update", value: %{id: item.entity.id}, target: @myself)
              })}
            </.cv_item>

            <.form_entity_panel>
              <button
                type="button"
                data-confirm="Delete this experience?"
                phx-value-id={item.entity.id}
                phx-click={JS.push("delete", target: @myself)}
                tabindex="-1"
                class="flex items-center"
              >
                <.icon name="hero-trash" class="size-4 text-rose-600" />
              </button>
              <span :if={length(@items) > 1} data-type="sort-handle" class="flex items-center">
                <.icon name="hero-bars-3" class="size-4 text-gray-600 cursor-move" />
              </span>
            </.form_entity_panel>
          </div>

          <div :if={@item_children != []}>
            {render_slot(@item_children, item.entity)}
          </div>
        </li>
      </ol>

      <div :if={@form != nil} class="relative group">
        <.cv_item>
          {@form_module.render_form(%{
            id: "#{@id}-form",
            form: @form,
            on_submit: JS.push("create", target: @myself)
          })}
        </.cv_item>

        <.form_entity_panel>
          <button type="button" tabindex="-1" phx-click={JS.push("hide_form", target: @myself)}>
            <.icon name="hero-x-mark" class="size-4" />
          </button>
        </.form_entity_panel>
      </div>

      <.form_entity_add_action
        :if={@form == nil}
        variant={@variant}
        on_click={JS.push("show_form", target: @myself)}
      />
    </div>
    """
  end

  attr :id, :string, required: true
  attr :controller, :any, required: true
  attr :form_module, :any, required: true
  attr :state, :map, required: true
  attr :variant, :atom, default: :full
  attr :on_change, :atom, default: nil

  slot :item_children

  def cv_form_list(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      controller={@controller}
      form_module={@form_module}
      state={@state}
      variant={@variant}
      on_change={@on_change}
      item_children={@item_children}
    />
    """
  end

  slot :inner_block, required: true

  defp form_entity_panel(assigns) do
    ~H"""
    <div
      class="absolute opacity-0 group-hover:opacity-100 bottom-full right-0 mb-1 bg-white px-2 py-1 rounded-lg ring-1 ring-gray-100 flex items-center gap-4 pointer-events-auto focus:outline-none"
      tabindex="0"
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :on_click, JS, default: %JS{}
  attr :variant, :atom, values: [:full, :tiny], default: :full

  defp form_entity_add_action(%{variant: :full} = assigns) do
    ~H"""
    <div class="relative flex items-center justify-center before:absolute before:h-px before:bg-gray-200 before:left-0 before:right-0">
      <button
        type="button"
        phx-click={@on_click}
        class="size-8 bg-black rounded-full flex items-center justify-center z-10"
      >
        <.icon name="hero-plus" class="size-6 text-white" />
      </button>
    </div>
    """
  end

  defp form_entity_add_action(%{variant: :tiny} = assigns) do
    ~H"""
    <div class="relative flex items-center justify-start before:absolute before:h-px before:bg-gray-200 before:left-0 before:right-0">
      <button
        type="button"
        phx-click={@on_click}
        class="size-6 bg-black rounded-lg flex items-center justify-center z-10"
      >
        <.icon name="hero-plus" class="size-5 text-white" />
      </button>
    </div>
    """
  end
end
