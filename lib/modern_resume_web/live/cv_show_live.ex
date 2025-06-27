defmodule ModernResumeWeb.CVShowLive do
  use ModernResumeWeb, :live_view

  import ModernResumeWeb.CV.LatexPreview
  import ModernResumeWeb.CV.Form

  alias ModernResume.Resume
  alias ModernResume.Resume.CV

  @impl true
  def mount(%{"cv_id" => id} = _params, _session, socket) when is_uuid(id) do
    case Resume.get_cv(id) do
      %CV{} = cv ->
        {:ok,
         socket
         |> assign(cv: cv)
         |> assign(form: CV.changeset(cv, %{}) |> to_form())
         |> assign(page_title: cv.title)}

      _ ->
        {:error,
         socket
         |> put_flash(:error, "CV not found")
         |> redirect(to: ~p"/cvs")}
    end
  end

  @impl true
  def handle_info({:cv_changed, %CV{} = cv}, socket) do
    {:noreply, socket |> assign(cv: cv)}
  end

  @impl true
  def handle_info({:preview, :error, reason}, socket) do
    {:noreply, socket |> put_flash(:error, "Error creating PDF: #{reason}")}
  end

  @impl true
  def handle_event("cv:save", %{"cv" => attrs}, socket) do
    case Resume.update_cv(socket.assigns.cv, attrs) do
      {:ok, %CV{} = cv} ->
        form = CV.changeset(cv, %{}) |> to_form()

        {:noreply,
         socket
         |> assign(cv: cv)
         |> assign(form: form)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(form: changeset |> to_form())}
    end
  end

  @impl true
  def handle_event("skills:" <> action, params, socket) do
    {:noreply, socket |> dispatch_entity(action, :skills, params)}
  end

  @impl true
  def handle_event("educations:" <> action, params, socket) do
    {:noreply, socket |> dispatch_entity(action, :educations, params)}
  end

  @impl true
  def handle_event("languages:" <> action, params, socket) do
    {:noreply, socket |> dispatch_entity(action, :languages, params)}
  end

  @impl true
  def handle_event("experiences:" <> action, params, socket) do
    {:noreply, socket |> dispatch_entity(action, :experiences, params)}
  end

  @impl true
  def handle_event("experience_details:add", %{"parent_id" => experience_id}, socket) do
    {:noreply, socket |> add_nested_entity_to(:experience_details, experience_id)}
  end

  defp dispatch_entity(socket, "add", key, _) when is_atom(key) do
    socket
    |> update(:form, fn %{source: changeset} ->
      changeset |> Resume.add_entity(key) |> to_form()
    end)
  end

  defp dispatch_entity(socket, "delete", key, %{"id" => id}) when is_atom(key) do
    case Resume.delete_entity(socket.assigns.cv, key, id) do
      {:ok, cv} ->
        socket
        |> assign(cv: cv)
        |> assign(form: CV.changeset(cv, %{}) |> to_form())

      {:error, changeset} ->
        socket
        |> assign(form: changeset |> to_form())
    end
  end

  defp dispatch_entity(socket, "sort", key, params) when is_atom(key) do
    case Resume.sort_entities(socket.assigns.cv, key, params) do
      {:ok, cv} ->
        form = CV.changeset(cv) |> to_form()

        socket
        |> assign(cv: cv)
        |> assign(form: form)

      {:error, %Ecto.Changeset{} = changeset} ->
        socket |> assign(form: to_form(changeset))

      {:error, _} ->
        socket |> put_flash(:error, "Unknown error")
    end
  end

  defp add_nested_entity_to(socket, key, id) do
    socket
    |> update(:form, fn %{source: changeset} ->
      changeset |> Resume.add_nested_entity(key, id) |> to_form()
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[auto_1fr] h-full p-6 ">
      <div class="grid grid-cols-3 items-center py-2">
        <.link navigate={~p"/cvs"} class="flex items-center gap-1">
          <.icon name="hero-chevron-left" class="size-4" />
          <span class="text-xs font-semibold">Back to list</span>
        </.link>
        <div class="flex items-center justify-center text-2xl font-bold whitespace-nowrap text-ellipsis">
          {@cv.title}
        </div>
        <div class="text-xs flex justify-end items-center">
          Last update: {@cv.updated_at |> Timex.format!("%Y-%m-%d %H:%M", :strftime)}
        </div>
      </div>

      <div class="w-full grid grid-cols-2 gap-4">
        <div class="relative h-full">
          <div class="overflow-scroll absolute left-0 right-0 top-0 bottom-0 pl-1 pr-5 pb-48 pt-4 flex flex-col gap-2 scroll-container-v">
            <.cv_form form={@form} />
          </div>
        </div>

        <.latex_preview id="cv_latex_preview" cv={@cv} on_render={:preview} />
      </div>
    </div>
    """
  end
end
