defmodule ModernResumeWeb.UserLive.Registration do
  use ModernResumeWeb, :live_view

  alias ModernResume.Accounts
  alias ModernResume.Accounts.User

  import ModernResumeWeb.FormComponents.Error

  def render(assigns) do
    ~H"""
    <Layouts.auth flash={@flash}>
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors} data-testid="error-form">
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.form_field field={@form[:email]} data-testid="email">
          <:label>Email</:label>
          <.input field={@form[:email]} type="email" />
        </.form_field>

        <.form_field field={@form[:password]} data-testid="password">
          <:label>Password</:label>
          <.input field={@form[:password]} type="password" />
        </.form_field>

        <.form_field field={@form[:password_confirmation]} data-testid="password-confirmation">
          <:label>Confirm Password</:label>
          <.input
            field={@form[:password_confirmation]}
            type="password"
            data-testid="input-password-confirmation"
          />
        </.form_field>

        <:actions>
          <.button
            phx-disable-with="Creating account..."
            class="w-full"
            data-testid="button-register"
          >
            Create an account
          </.button>
          <.social_button
            provider="github"
            url={~p"/auth/github"}
            label="Sign up with GitHub"
            data-testid="button-register-github"
          />
          <.social_button
            provider="google"
            url={~p"/auth/google"}
            label="Sign up with Google"
            data-testid="button-register-google"
          />
        </:actions>
      </.simple_form>
    </Layouts.auth>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
