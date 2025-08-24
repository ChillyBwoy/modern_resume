defmodule ModernResumeWeb.CVLive.List do
  use ModernResumeWeb, :live_view

  import ModernUI.Components.Button
  import ModernUI.Components.DropdownMenu
  import ModernUI.Components.FormField
  import ModernUI.Components.Icon
  import ModernUI.Components.Input
  import ModernUI.Components.Modal

  alias ModernResume.Resume
  alias ModernResume.Resume.CV
  alias ModernResumeWeb.Formatters

  @impl true
  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(cvs: Resume.list_cvs_for(user))
     |> assign(create_form: CV.changeset(%CV{}, %{email: user.email}) |> to_form())
     |> assign_cv_operation(params)}
  end

  defp assign_cv_operation(socket, params) do
    case Map.fetch(params, "cv_id") do
      {:ok, cv_id} ->
        socket |> assign(cv_id: cv_id)

      _ ->
        socket |> assign(cv_id: nil)
    end
  end

  @impl true
  def handle_event("delete", %{"id" => cv_id}, socket) when is_uuid(cv_id) do
    case Resume.delete_cv(socket.assigns.current_user, cv_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "CV deleted")
         |> redirect(to: ~p"/", replace: true)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Unable to delete CV")
         |> redirect(to: ~p"/", replace: true)}
    end
  end

  @impl true
  def handle_event("duplicate", %{"id" => cv_id}, socket) when is_uuid(cv_id) do
    case Resume.duplicate_cv(socket.assigns.current_user, cv_id) do
      {:ok, %CV{} = new_cv} ->
        {:noreply,
         socket
         |> put_flash(:info, "CV duplicated successfully.")
         |> redirect(to: ~p"/cvs/#{new_cv.id}", replace: true)}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Unable to copy CV")
         |> redirect(to: ~p"/", replace: true)}
    end
  end

  @impl true
  def handle_event("validate", %{"cv" => params}, socket) do
    changeset = CV.changeset(%CV{}, params) |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("create", %{"cv" => params}, socket) do
    user = socket.assigns.current_user
    payload = Map.put(params, "user_id", user.id)

    with {:ok, %CV{} = cv} <- Resume.create_cv(payload) do
      {:noreply,
       socket
       |> put_flash(:info, "CV created successfully.")
       |> redirect(to: ~p"/cvs/#{cv.id}", replace: true)}
    else
      {:error, changeset} ->
        {:noreply, socket |> assign(create_form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <.modal
        :if={@live_action == :new}
        id="create-cv-modal"
        on_cancel={JS.navigate(~p"/", replace: true)}
        data-testid="create-new-cv-modal"
      >
        <:title>Create new CV</:title>
        <.form for={@create_form} phx-change="validate" phx-submit="create">
          <.form_field field={@create_form[:title]} data-testid="title">
            <:label>Title</:label>
            <.input field={@create_form[:title]} />
          </.form_field>

          <.inputs_for :let={content} field={@create_form[:content]}>
            <.form_field field={content[:name]} data-testid="name">
              <:label>Name</:label>
              <.input field={content[:name]} />
            </.form_field>

            <.form_field field={content[:position]} data-testid="position">
              <:label>Position</:label>
              <.input field={content[:position]} />
            </.form_field>
          </.inputs_for>

          <.button variant="primary" type="submit">Save</.button>
        </.form>
      </.modal>

      <.modal
        :if={@live_action == :delete}
        id="delete-cv-modal"
        size="auto"
        on_cancel={JS.navigate(~p"/", replace: true)}
      >
        <:title>Are you sure you want to delete this CV?</:title>
        <div class="flex items-center justify-center gap-4">
          <.button variant="danger" phx-value-id={@cv_id} phx-click="delete">Yes</.button>
          <.button variant="none" phx-click={JS.navigate(~p"/", replace: true)}>Cancel</.button>
        </div>
      </.modal>

      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900" data-testid="cv-list-page-title">My CVs</h1>

        <.button
          type="button"
          variant="primary"
          phx-click={JS.navigate(~p"/cvs/new")}
          data-testid="button-create-new-cv"
        >
          <.icon name="mdi-plus" class="mr-2" />
          <span>Create New CV</span>
        </.button>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          :for={cv <- @cvs}
          class="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200 grid grid-cols-[1fr_auto] justify-between h-full p-4"
        >
          <.link
            navigate={~p"/cvs/#{cv.id}"}
            class="flex flex-col justify-between items-start mb-2 text-xl font-semibold text-gray-900 h-full"
          >
            {cv.title}
            <span class="text-lg text-gray-600">{cv.content.position}</span>
            <span class="flex items-center text-sm text-gray-500 gap-2">
              <.icon name="mdi-calendar-month-outline" />
              <span>{Formatters.format_datetime(cv.inserted_at)}</span>
            </span>
          </.link>

          <.dropdown_menu id={"#{cv.id}-menu"}>
            <:item
              variant="secondary"
              icon="mdi-file-document-multiple-outline"
              action={JS.push("duplicate", value: %{id: cv.id})}
            >
              Duplicate
            </:item>
            <:item
              variant="danger"
              icon="mdi-delete-outline"
              action={JS.navigate(~p"/cvs/#{cv.id}/delete")}
            >
              Delete
            </:item>
          </.dropdown_menu>
        </div>
      </div>

      <div :if={Enum.empty?(@cvs)} class="text-center py-12">
        <div class="text-gray-500">
          <.icon
            name="mdi-file-document-outline"
            class="size-16 mx-auto mb-4 flex flex-col gap-4"
          />
          <p class="text-lg">No resumes yet</p>
          <p class="text-sm">Click the button above to create your first resume</p>
        </div>
      </div>
      <%!-- </div> --%>
    </Layouts.app>
    """
  end
end
