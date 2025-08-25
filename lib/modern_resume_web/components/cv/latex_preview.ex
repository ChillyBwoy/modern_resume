defmodule ModernResumeWeb.CV.LatexPreview do
  use Phoenix.Component

  import ModernUI.Components.Icon

  attr :title, :string, required: true
  attr :variant, :atom, values: [:default, :error], default: :default

  defp message(assigns) do
    ~H"""
    <div class={[
      "relative flex items-center justify-center",
      @variant == :error && "text-danger"
    ]}>
      {@title}
    </div>
    """
  end

  attr :id, :string, required: true
  attr :state, ModernResumeWeb.Document.RenderState, required: true

  slot :panel, required: false

  def latex_preview(assigns) do
    ~H"""
    <div class="relative h-full w-full grid grid-rows-[auto_1fr] shadow-xl rounded-lg overflow-hidden">
      <div class="bg-gray-200 p-2 flex gap-4 items-center">
        {render_slot(@panel)}
      </div>

      <%= if @state.status == :error do %>
        <.message title="Error rendering PDF" variant={:error} />
      <% else %>
        <%= case @state.content_type do %>
          <% :str -> %>
            <%= if @state.content_str != nil do %>
              <div class="relative">
                <pre class="overflow-scroll absolute left-0 right-0 top-0 bottom-0 text-xs p-4 whitespace-pre-wrap bg-form-background">{@state.content_str}</pre>
              </div>
            <% else %>
              <.message title="Preparing LaTeX..." />
            <% end %>
          <% :pdf -> %>
            <%= if @state.content_pdf != nil do %>
              <embed
                src={"data:application/pdf;base64,#{@state.content_pdf}"}
                width="100%"
                height="100%"
                type="application/pdf"
                class="w-full h-full"
              />
            <% else %>
              <.message title="Building PDF..." />
            <% end %>
          <% _ -> %>
            <.message title="No preview available" />
        <% end %>
      <% end %>

      <%= if @state.status == :loading do %>
        <div class="absolute top-0 right-0 bottom-0 left-0 bg-black/20 flex items-center justify-center">
          <.icon name="mdi-autorenew" class="size-20 text-white animate-spin -mt-20" />
        </div>
      <% end %>
    </div>
    """
  end
end
