defmodule ModernResumeWeb.CV.LatexPreview do
  use Phoenix.Component

  import ModernResumeWeb.CoreComponents

  attr :id, :string, required: true
  attr :state, ModernResumeWeb.Renderer.RenderState, required: true
  attr :toggle, :string, default: nil

  def latex_preview(assigns) do
    ~H"""
    <div class="relative h-full w-full grid grid-rows-[auto_1fr] shadow-xl rounded-lg overflow-hidden">
      <div class="bg-gray-200 p-2 flex gap-4 items-center">
        <.button type="button" phx-click={@toggle}>
          <.icon
            name={if @state.status == :pdf, do: "hero-code-bracket", else: "hero-document-check"}
            class="size-5"
          />
        </.button>
        <.button :if={@state.status == :source} type="button">
          <.icon name="hero-clipboard-document" class="size-5" />
        </.button>
      </div>

      <%= if @state.status == :error do %>
        TODO: ERROR
      <% else %>
        <%= case @state.content_type do %>
          <% :str -> %>
            <div class="relative">
              <pre class="overflow-scroll absolute left-0 right-0 top-0 bottom-0 text-xs p-4 whitespace-pre-wrap bg-form-background">{@state.content_str}</pre>
            </div>
          <% :pdf -> %>
            <embed
              src={"data:application/pdf;base64,#{@state.content_pdf}"}
              width="100%"
              height="100%"
              type="application/pdf"
              class="w-full h-full"
            />
          <% _ -> %>
            <div class="relative flex items-center justify-center">
              <%!-- <.icon name="hero-no-symbol" class="size-20" /> --%>
            </div>
        <% end %>
      <% end %>

      <%= if @state.status == :loading do %>
        <div class="absolute top-0 right-0 bottom-0 left-0 bg-black/20 flex items-center justify-center">
          <.icon name="hero-arrow-path" class="size-12 text-white animate-spin" />
        </div>
      <% end %>
    </div>
    """
  end
end
