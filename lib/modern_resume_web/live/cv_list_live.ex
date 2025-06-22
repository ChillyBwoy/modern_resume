defmodule ModernResumeWeb.CVListLive do
  use ModernResumeWeb, :live_view

  alias ModernResume.Resume

  import ModernResumeWeb.CV.CreateForm

  @impl true
  def mount(_params, _session, socket) do
    cvs = socket.assigns.current_user |> Resume.list_cvs_for()

    {:ok, socket |> assign(cvs: cvs)}
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
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <.modal
        :if={@live_action == :new}
        id="create-cv-modal"
        on_cancel={JS.navigate(~p"/cvs", replace: true)}
        show
      >
        <.create_form id="create-cv" user={@current_user} />
      </.modal>

      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900">My CVs</h1>
        <.link
          navigate={~p"/cvs/new"}
          class="inline-flex items-center px-4 py-2 bg-orange-400 text-white rounded-lg"
        >
          <.icon name="hero-plus" class="size-5 mr-2" />
          <span>Create New CV</span>
        </.link>
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
            <span class="text-lg text-gray-600">TODO: position</span>
            <span class="flex items-center text-sm text-gray-500 gap-2">
              <.icon name="hero-calendar" class="size-4" />
              <span>Created {cv.inserted_at |> Date.to_string()}</span>
            </span>
          </.link>

          <button
            phx-click={JS.push("delete", value: %{id: cv.id})}
            phx-value-id={cv.id}
            data-confirm="Are you sure you want to delete this CV?"
            class="text-red-600 hover:text-red-800"
          >
            <.icon name="hero-trash" class="size-5" />
          </button>
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
