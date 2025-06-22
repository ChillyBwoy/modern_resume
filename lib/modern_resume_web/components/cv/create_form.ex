defmodule ModernResumeWeb.CV.CreateForm do
  use ModernResumeWeb, :live_component
  use Phoenix.Component

  alias ModernResume.Resume
  alias ModernResume.Resume.CV

  attr :id, :string, required: true
  attr :user, ModernResume.Accounts.User, required: true

  def create_form(assigns) do
    ~H"""
    <.live_component module={__MODULE__} id={@id} user={@user} />
    """
  end

  @impl true
  def update(assigns, socket) do
    user = assigns.user

    changeset = %CV{} |> CV.changeset(%{email: user.email})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"cv" => params}, socket) do
    changeset = CV.changeset(%CV{}, params) |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("submit", %{"cv" => params}, socket) do
    user = socket.assigns.user
    payload = Map.put(params, "user_id", user.id)

    with {:ok, %CV{} = cv} <- Resume.create_cv(payload) do
      {:noreply,
       socket
       |> put_flash(:info, "CV created successfully.")
       |> redirect(to: ~p"/cvs/#{cv.id}", replace: true)}
    else
      {:error, changeset} ->
        {:noreply, socket |> assign(form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-target={@myself} phx-change="validate" phx-submit="submit">
        <.input field={@form[:title]} label="Title" />

        <:actions>
          <.button type="submit">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
