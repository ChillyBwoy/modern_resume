defmodule ModernResumeWeb.CV.LatexPreview do
  use ModernResumeWeb, :live_component
  use Phoenix.Component

  attr :id, :string, required: true
  attr :state, ModernResumeWeb.Renderer.State, required: true

  def latex_preview(assigns) do
    ~H"""
    <.live_component module={__MODULE__} id={@id} state={@state} />
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def handle_event("toggle", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative h-full w-full grid grid-rows-[auto_1fr] shadow-xl rounded-lg overflow-hidden">
      <div class="bg-gray-200 p-2 flex gap-4 items-center">
        <.button type="button" phx-target={@myself} phx-click="toggle">
          <.icon
            name={if @state.status == :pdf, do: "hero-code-bracket", else: "hero-document-check"}
            class="size-5"
          />
        </.button>
        <.button :if={@state.status == :source} type="button">
          <.icon name="hero-clipboard-document" class="size-5" />
        </.button>
      </div>

      <%= if @state.status == :idle do %>
        <div class="relative flex items-center justify-center">
          <.icon name="hero-no-symbol" class="size-20" />
        </div>
      <% end %>

      <%= if @state.status == :source do %>
        <div class="relative">
          <pre class="overflow-scroll absolute left-0 right-0 top-0 bottom-0 text-xs p-4 whitespace-pre-wrap bg-form-background">{@state.content}</pre>
        </div>
      <% end %>

      <%= if @state.status == :pdf do %>
        <embed
          src={"data:application/pdf;base64,#{@state.content}"}
          width="100%"
          height="100%"
          type="application/pdf"
          class="w-full h-full"
        />
      <% end %>

      <%= if @state.status == :loading do %>
        <div class="absolute top-0 right-0 bottom-0 left-0 bg-black/20 flex items-center justify-center">
          <.icon name="hero-no-symbol" class="size-20" />
        </div>
      <% end %>
    </div>
    """
  end
end
