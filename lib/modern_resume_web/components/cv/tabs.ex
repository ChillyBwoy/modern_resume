defmodule ModernResumeWeb.CV.Tabs do
  use ModernResumeWeb, :live_component
  use Phoenix.Component

  attr :id, :string, required: true

  slot :tab, required: true do
    attr :title, :string, required: true
  end

  def tabs(assigns) do
    ~H"""
    <.live_component module={__MODULE__} id={@id} tab={@tab} active={0} />
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_content(assigns.active)}
  end

  @impl true
  def handle_event("select", %{"index" => index}, socket) do
    idx = String.to_integer(index)

    {:noreply,
     socket
     |> assign(active: idx)
     |> assign_content(idx)}
  end

  defp assign_content(socket, idx) when is_integer(idx) do
    socket |> assign(content: Enum.at(socket.assigns.tab, idx, nil))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative">
      <ul class="flex items-center">
        <li
          :for={{tab, index} <- Enum.with_index(@tab)}
          class={[
            "p-2",
            index == @active && "bg-primary-light text-white",
            index != @active && "bg-secondary-light cursor-pointer"
          ]}
          phx-target={@myself}
          phx-value-index={index}
          phx-click="select"
        >
          {tab.title}
        </li>
      </ul>
      <div :if={@content != nil} class="relative">
        {render_slot(@content)}
      </div>
    </div>
    """
  end
end
