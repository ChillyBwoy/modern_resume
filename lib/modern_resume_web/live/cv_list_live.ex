defmodule ModernResumeWeb.CVListLive do
  use ModernResumeWeb, :live_view

  alias ModernResume.Resume
  alias ModernResume.Resume.CV

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(cvs: Resume.list_cvs_for(user))
     |> assign(create_form: CV.changeset(%CV{}, %{email: user.email}) |> to_form())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with cv <- Resume.get_cv(id),
         {:ok, _} <- Resume.delete_cv(cv) do
      cvs = Resume.list_cvs_for(socket.assigns.current_user)
      {:noreply, socket |> assign(cvs: cvs)}
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
        on_cancel={JS.navigate(~p"/cvs", replace: true)}
        show
      >
        <.simple_form for={@create_form} phx-change="validate" phx-submit="create">
          <.input field={@create_form[:title]} label="Title" />

          <.inputs_for :let={content} field={@create_form[:content]}>
            <.input field={content[:name]} label="Name" />
            <.input field={content[:position]} label="Position" />
          </.inputs_for>

          <:actions>
            <.button type="submit">Save</.button>
          </:actions>
        </.simple_form>
      </.modal>

      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900">My CVs</h1>

        <.button type="button" phx-click={JS.navigate(~p"/cvs/new")}>
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
              <span>{cv.inserted_at |> Timex.format!("%B %d, %Y %H:%M", :strftime)}</span>
            </span>
          </.link>

          <div>
            <button
              phx-click="delete"
              phx-value-id={cv.id}
              data-confirm="Are you sure you want to delete this CV?"
              class="text-red-600 hover:text-red-800 cursor-pointer"
            >
              <.icon name="hero-trash" class="size-5" />
            </button>
          </div>
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
