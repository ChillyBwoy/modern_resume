defmodule ModernResumeWeb.CV.LatexPreview do
  use ModernResumeWeb, :live_component
  use Phoenix.Component

  alias ModernResume.Resume.CV
  alias ModernResumeWeb.Renderer.Moderncv

  attr :id, :string, required: true
  attr :cv, CV, required: true
  attr :class, :string, default: nil
  attr :on_render, :atom, default: nil

  def latex_preview(assigns) do
    ~H"""
    <.live_component module={__MODULE__} id={@id} cv={@cv} on_render={@on_render} class={@class} />
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(pdf: nil)}
  end

  @impl true
  def handle_event("toggle", _, socket) do
    if socket.assigns.pdf != nil do
      {:noreply, socket |> assign(pdf: nil)}
    else
      case Moderncv.render(socket.assigns.cv, :pdf) do
        {:ok, pdf} ->
          {:noreply, socket |> assign(pdf: pdf)}

        {:error, msg} ->
          {:noreply, socket |> assign(pdf: nil) |> notify({:error, msg})}
      end
    end
  end

  defp notify(socket, payload) do
    with {:ok, reason} when not is_nil(reason) <- Map.fetch(socket.assigns, :on_render) do
      case payload do
        {:ok, data} ->
          send(self(), {reason, :ok, data})

        {:error, msg} ->
          send(self(), {reason, :error, msg})
      end
    end

    socket
  end

  @impl true
  def render(assigns) do
    cv = assigns.cv
    {:ok, content} = Moderncv.render(cv, :string)
    assigns = assign(assigns, tpl: content)

    ~H"""
    <div class="relative h-full w-full grid grid-rows-[auto_1fr] shadow-xl rounded-lg overflow-hidden">
      <div class="bg-gray-200 p-2">
        <.button type="button" phx-target={@myself} phx-click="toggle" phx-disable-with="...">
          <.icon
            name={if @pdf != nil, do: "hero-code-bracket", else: "hero-document-check"}
            class="size-5"
          />
        </.button>
      </div>
      <%= if @pdf != nil do %>
        <embed
          src={"data:application/pdf;base64,#{@pdf}"}
          width="100%"
          height="100%"
          type="application/pdf"
          class="w-full h-full"
        />
      <% else %>
        <div class="relative">
          <pre class="overflow-scroll absolute left-0 right-0 top-0 bottom-0 text-xs p-4">{@tpl}</pre>
        </div>
      <% end %>
    </div>
    """
  end
end
