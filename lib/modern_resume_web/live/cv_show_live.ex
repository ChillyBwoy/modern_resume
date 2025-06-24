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
  def handle_event("skill:add", _, socket) do
    {:noreply, socket |> add_entry(:skills)}
  end

  @impl true
  def handle_event("skill:delete", params, _socket) do
    dbg(params)
    raise "not implemented"
  end

  @impl true
  def handle_event("skills:sort", params, socket) do
    {:noreply, socket |> sort_entries(:skills, params)}
  end

  @impl true
  def handle_event("experience:add", _params, socket) do
    {:noreply, socket |> add_entry(:experiences)}
  end

  @impl true
  def handle_event("experience:delete", params, _socket) do
    dbg(params)
    raise "not implemented"
  end

  @impl true
  def handle_event("experiences:sort", params, socket) do
    {:noreply, socket |> sort_entries(:experiences, params)}
  end

  @impl true
  def handle_event("education:add", _, socket) do
    {:noreply, socket |> add_entry(:educations)}
  end

  @impl true
  def handle_event("education:delete", params, _socket) do
    dbg(params)
    raise "not implemented"
  end

  @impl true
  def handle_event("educations:sort", params, socket) do
    {:noreply, socket |> sort_entries(:educations, params)}
  end

  @impl true
  def handle_event("language:add", _, socket) do
    {:noreply, socket |> add_entry(:languages)}
  end

  @impl true
  def handle_event("language:delete", params, _socket) do
    dbg(params)
    raise "not implemented"
  end

  @impl true
  def handle_event("languages:sort", params, socket) do
    {:noreply, socket |> sort_entries(:languages, params)}
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

  defp add_entry(socket, key) do
    socket
    |> update(:form, fn %{source: changeset} ->
      changeset |> Resume.add_entity(key) |> to_form()
    end)
  end

  defp sort_entries(socket, key, params) when is_atom(key) and is_list(params) do
    {:ok, cv} = Resume.sort_entities(socket.assigns.cv, key, params)
    form = CV.changeset(cv, %{}) |> to_form()

    socket
    |> assign(cv: cv)
    |> assign(form: form)
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
            <.cv_form form={@form} />
          </div>
        </div>

        <.latex_preview id="cv_latex_preview" cv={@cv} on_render={:preview} />
      </div>
    </div>
    """
  end
end
