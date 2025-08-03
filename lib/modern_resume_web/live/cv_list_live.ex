defmodule ModernResumeWeb.CVListLive do
  use ModernResumeWeb, :live_view

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
    <div class="container mx-auto px-4 py-8">
      <.modal
        :if={@live_action == :new}
        id="create-cv-modal"
        on_cancel={JS.navigate(~p"/", replace: true)}
        show
      >
        <div class="flex flex-col gap-4">
          <.header>Create new CV</.header>
          <.simple_form for={@create_form} phx-change="validate" phx-submit="create">
            <.input field={@create_form[:title]} label="Title" />

            <.inputs_for :let={content} field={@create_form[:content]}>
              <.input field={content[:name]} label="Name" />
              <.input field={content[:position]} label="Position" />
            </.inputs_for>

            <:actions>
              <.button variant={:primary} type="submit">Save</.button>
            </:actions>
          </.simple_form>
        </div>
      </.modal>

      <.modal
        :if={@live_action == :delete}
        id="delete-cv-modal"
        on_cancel={JS.navigate(~p"/", replace: true)}
        show
      >
        <div class="flex flex-col gap-4">
          <.header>Are you sure you want to delete this CV?</.header>
          <div class="flex items-center justify-end gap-4">
            <.button variant={:danger} phx-value-id={@cv_id} phx-click="delete">Yes</.button>
            <.button variant={:none} phx-click={JS.navigate(~p"/", replace: true)}>Cancel</.button>
          </div>
        </div>
      </.modal>

      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900">My CVs</h1>

        <.button type="button" variant={:primary} phx-click={JS.navigate(~p"/cvs/new")}>
          <.icon name="hero-plus" class="size-5 mr-2" />
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
              <.icon name="hero-calendar" class="size-4" />
              <span>{Formatters.format_datetime(cv.inserted_at)}</span>
            </span>
          </.link>

          <.dropdown_menu id={"#{cv.id}-menu"}>
            <:item
              variant={:secondary}
              icon="hero-document-duplicate"
              action={JS.push("duplicate", value: %{id: cv.id})}
            >
              Duplicate
            </:item>
            <:item variant={:danger} icon="hero-trash" action={JS.navigate(~p"/cvs/#{cv.id}/delete")}>
              Delete
            </:item>
          </.dropdown_menu>
        </div>
      </div>

      <div :if={Enum.empty?(@cvs)} class="text-center py-12">
        <div class="text-gray-500">
          <.icon name="hero-document-text" class="size-16 mx-auto mb-4 flex flex-col gap-4" />
          <p class="text-lg">No resumes yet</p>
          <p class="text-sm">Click the button above to create your first resume</p>
        </div>
      </div>
    </div>
    """
  end
end
