defmodule ModernResumeWeb.CVShowLive do
  use ModernResumeWeb, :live_view

  import ModernResumeWeb.CV.LatexPreview
  import ModernResumeWeb.CV.Form

  alias ModernResume.Resume
  alias ModernResume.Resume.CV
  alias ModernResumeWeb.Renderer.RenderWorker
  alias ModernResumeWeb.Renderer.RenderState

  @impl true
  def mount(%{"cv_id" => id} = _params, _session, socket) when is_uuid(id) do
    if connected?(socket) do
      RenderWorker.subscribe()
    end

    user = socket.assigns.current_user

    case Resume.get_cv_for(user, id) do
      %CV{} = cv ->
        initial_state = RenderState.init() |> RenderState.content_type(:pdf)

        {:ok,
         socket
         |> assign(cv: cv)
         |> assign(state: initial_state)
         |> assign(form: CV.changeset(cv, %{}) |> to_form())
         |> assign(page_title: cv.title)
         |> render_cv(cv)}

      _ ->
        {:error,
         socket
         |> put_flash(:error, "CV not found")
         |> redirect(to: ~p"/cvs")}
    end
  end

  @impl true
  def handle_info({:renderer, data}, socket) do
    state = socket.assigns.state

    case data do
      {:ok, :str, content} ->
        {:noreply,
         socket
         |> assign(state: RenderState.success(state, :str, content))}

      {:ok, :pdf, content} ->
        {:noreply,
         socket
         |> assign(state: RenderState.success(state, :pdf, content))}

      {:error, msg} ->
        {:noreply,
         socket
         |> assign(state: RenderState.error(state, msg))}
    end
  end

  @impl true
  def handle_event("cv:save", %{"cv" => attrs}, socket) do
    case Resume.update_cv(socket.assigns.cv, attrs) do
      {:ok, %CV{} = cv} ->
        {:noreply,
         socket
         |> assign(cv: cv)
         |> assign(form: CV.changeset(cv) |> to_form())
         |> render_cv(cv)}

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
  def handle_event("experience_details:add", %{"parent_id" => parent_id}, socket) do
    {:noreply,
     socket
     |> update(:form, fn %{source: changeset} ->
       changeset |> Resume.add_nested_entity({:experiences, :details}, parent_id) |> to_form()
     end)}
  end

  @impl true
  def handle_event("experience_details:delete", %{"id" => id}, socket) do
    case Resume.delete_nested_entity(socket.assigns.cv, {:experiences, :details}, id) do
      {:ok, cv} ->
        {:noreply,
         socket
         |> assign(cv: cv)
         |> assign(form: CV.changeset(cv, %{}) |> to_form())
         |> render_cv(cv)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(form: changeset |> to_form())}
    end
  end

  @impl true
  def handle_event(
        "experience_details:sort",
        %{"ids" => ordered_ids, "parent_id" => parent_id},
        socket
      ) do
    case Resume.sort_nested_entities(
           socket.assigns.cv,
           {:experiences, :details},
           parent_id,
           ordered_ids
         ) do
      {:ok, cv} ->
        form = CV.changeset(cv) |> to_form()

        {:noreply,
         socket
         |> assign(cv: cv)
         |> assign(form: form)
         |> render_cv(cv)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("toggle", _, socket) do
    {:noreply,
     socket
     |> assign(state: RenderState.toggle_content_type(socket.assigns.state))
     |> render_cv(socket.assigns.cv)}
  end

  defp dispatch_entity(socket, "add", key, _) when is_atom(key) do
    case Resume.add_entity(socket.assigns.cv, key) do
      {:ok, cv} ->
        socket
        |> assign(cv: cv)
        |> assign(form: CV.changeset(cv) |> to_form())
        |> render_cv(cv)

      {:error, changeset} ->
        socket
        |> assign(form: changeset |> to_form())
    end
  end

  defp dispatch_entity(socket, "delete", key, %{"id" => id}) when is_atom(key) do
    case Resume.delete_entity(socket.assigns.cv, key, id) do
      {:ok, cv} ->
        socket
        |> assign(cv: cv)
        |> assign(form: CV.changeset(cv) |> to_form())
        |> render_cv(cv)

      {:error, changeset} ->
        socket
        |> assign(form: changeset |> to_form())
    end
  end

  defp dispatch_entity(socket, "sort", key, %{"ids" => ordered_ids}) when is_atom(key) do
    case Resume.sort_entities(socket.assigns.cv, key, ordered_ids) do
      {:ok, cv} ->
        form = CV.changeset(cv) |> to_form()

        socket
        |> assign(cv: cv)
        |> assign(form: form)
        |> render_cv(cv)

      {:error, %Ecto.Changeset{} = changeset} ->
        socket |> assign(form: to_form(changeset))

      {:error, _} ->
        socket |> put_flash(:error, "Unknown error")
    end
  end

  defp render_cv(socket, %CV{} = cv) do
    content_type = Map.get(socket.assigns.state, :content_type, :pdf)

    Supervisor.start_link(
      [
        {RenderWorker, {cv, content_type}}
      ],
      strategy: :one_for_one
    )

    socket |> assign(state: RenderState.loading(socket.assigns.state))
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

        <.latex_preview id="cv_latex_preview" state={@state} toggle="toggle" />
      </div>
    </div>
    """
  end
end
