defmodule ModernResumeWeb.CVShowLive do
  use ModernResumeWeb, :live_view

  import ModernResumeWeb.CV.LatexPreview

  alias ModernResume.Resume
  alias ModernResume.Resume.CV

  @impl true
  def mount(%{"cv_id" => id} = _params, _session, socket) when is_uuid(id) do
    case Resume.get_cv(id) do
      %CV{} = cv ->
        {:ok, assign(socket, cv: cv, page_title: cv.title)}

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
  def handle_info(:update, socket) do
    cv = Resume.get_cv(socket.assigns.cv.id)
    {:noreply, socket |> assign(cv: cv)}
  end

  @impl true
  def handle_info({:preview, :ok, _}, socket) do
    {:noreply, socket |> put_flash(:info, "PDF created successfully")}
  end

  @impl true
  def handle_info({:preview, :error, reason}, socket) do
    {:noreply, socket |> put_flash(:error, "Error creating PDF: #{reason}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[auto_1fr] h-full p-6">
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
            <div>TODO: ContentForm</div>

            <.cv_section title="Skills">
              TODO: ContentSkillsForm
            </.cv_section>

            <.cv_section title="Experience">
              TODO: ExperienceForm
            </.cv_section>

            <.cv_section title="Education">
              TODO: EducationForm
            </.cv_section>

            <.cv_section title="Foreign Languages">
              TODO: ForeignLanguages
            </.cv_section>
          </div>
        </div>

        <.latex_preview id="cv_latex_preview" cv={@cv} on_render={:preview} />
      </div>
    </div>
    """
  end
end
