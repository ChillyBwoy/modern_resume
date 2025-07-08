defmodule ModernResumeWeb.CVShowLive do
  use ModernResumeWeb, :live_view

  import ModernResumeWeb.CV.LatexPreview
  import ModernResumeWeb.CV.ContentForm
  import ModernResumeWeb.CV.Tabs

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
         |> assign(selected_tab: "personal")
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
  def handle_event("social_networks:" <> action, params, socket) do
    {:noreply, socket |> dispatch_entity(action, :social_networks, params)}
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

  def handle_event("tabs:select", %{"tab" => tab}, socket) do
    {:noreply, socket |> assign(selected_tab: tab)}
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
          <.form
            for={@form}
            phx-change="cv:save"
            phx-submit="cv:save"
            class="grid grid-rows-[auto_1fr_auto] h-full"
          >
            <div class="relative mb-6">
              <.input field={@form[:title]} label="Title" phx-debounce="blur" />
            </div>

            <.inputs_for :let={content} field={@form[:content]}>
              <.tabs
                selected={@selected_tab}
                on_select={fn tab_name -> JS.push("tabs:select", value: %{tab: tab_name}) end}
              >
                <:tab name="personal" title="Personal Information">
                  <.scroll_container>
                    <.fieldset id="basic_info" title="Personal Information">
                      <.personal_info_form form={content} />
                    </.fieldset>
                  </.scroll_container>
                </:tab>

                <:tab name="skills" title="Skills">
                  <.scroll_container>
                    <.fieldset id="skills" title="Skills" on_add="skills:add" on_sort="skills:sort">
                      <.inputs_for :let={skill} field={content[:skills]}>
                        <.skill_form
                          form={skill}
                          index={skill.index}
                          sortable={is_sortable(content, :skills)}
                          on_delete="skills:delete"
                        />
                      </.inputs_for>
                    </.fieldset>
                  </.scroll_container>
                </:tab>

                <:tab name="experience" title="Experience">
                  <.scroll_container>
                    <.fieldset
                      id="experiences"
                      title="Experience"
                      on_add="experiences:add"
                      on_sort="experiences:sort"
                    >
                      <.inputs_for :let={experience} field={content[:experiences]}>
                        <.experience_form
                          form={experience}
                          index={experience.index}
                          sortable={is_sortable(content, :experiences)}
                          on_delete="experiences:delete"
                          on_detail_delete="experience_details:delete"
                        />
                      </.inputs_for>
                    </.fieldset>
                  </.scroll_container>
                </:tab>

                <:tab name="education" title="Education">
                  <.scroll_container>
                    <.fieldset
                      id="educations"
                      title="Education"
                      on_add="educations:add"
                      on_sort="educations:sort"
                    >
                      <.inputs_for :let={education} field={content[:educations]}>
                        <.education_form
                          form={education}
                          index={education.index}
                          sortable={is_sortable(content, :educations)}
                          on_delete="educations:delete"
                        />
                      </.inputs_for>
                    </.fieldset>
                  </.scroll_container>
                </:tab>

                <:tab name="social_networks" title="Social Networks">
                  <.scroll_container>
                    <.fieldset
                      id="social_networks"
                      title="Social Networks"
                      on_add="social_networks:add"
                      on_sort="social_networks:sort"
                    >
                      <.inputs_for :let={social_network} field={content[:social_networks]}>
                        <.social_network_form
                          form={social_network}
                          index={social_network.index}
                          sortable={is_sortable(content, :social_networks)}
                          on_delete="social_networks:delete"
                        />
                      </.inputs_for>
                    </.fieldset>
                  </.scroll_container>
                </:tab>

                <:tab name="foreign_languages" title="Foreign Languages">
                  <.scroll_container>
                    <.fieldset
                      id="languages"
                      title="Foreign Languages"
                      on_add="languages:add"
                      on_sort="languages:sort"
                    >
                      <.inputs_for :let={language} field={content[:languages]}>
                        <.language_form
                          form={language}
                          index={language.index}
                          sortable={is_sortable(content, :languages)}
                          on_delete="languages:delete"
                        />
                      </.inputs_for>
                    </.fieldset>
                  </.scroll_container>
                </:tab>

                <:tab name="settings" title="Settings">
                  <.scroll_container>
                    <.fieldset id="settings" title="Settings">
                      <.inputs_for :let={settings} field={content[:settings]}>
                        <.settings_form form={settings} />
                      </.inputs_for>
                    </.fieldset>
                  </.scroll_container>
                </:tab>
              </.tabs>
            </.inputs_for>

            <div class="p-4">
              <.button type="submit">Save</.button>
            </div>
          </.form>
        </div>

        <.latex_preview id="cv_latex_preview" state={@state} toggle="toggle" />
      </div>
    </div>
    """
  end
end
