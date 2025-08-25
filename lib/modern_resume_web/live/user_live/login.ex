defmodule ModernResumeWeb.UserLive.Login do
  use ModernResumeWeb, :live_view

  import ModernUI.Components.Button
  import ModernUI.Components.FormField
  import ModernUI.Components.Header
  import ModernUI.Components.Input

  def render(assigns) do
    ~H"""
    <Layouts.auth flash={@flash}>
      <.header class="text-center">
        Sign in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.form_field field={@form[:email]} data-testid="email">
          <:label>Email</:label>
          <.input field={@form[:email]} type="email" required />
        </.form_field>

        <.form_field field={@form[:password]} data-testid="password">
          <:label>Password</:label>
          <.input field={@form[:password]} type="password" required />
        </.form_field>

        <.form_field field={@form[:remember_me]} position={:left} data-testid="keep-logged-in">
          <:label>Keep me logged in</:label>
          <.input field={@form[:remember_me]} type="checkbox" />
        </.form_field>

        <:actions>
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>

        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full" data-testid="button-signin">
            Sign in
          </.button>
        </:actions>

        <:actions>
          <.social_button
            provider="github"
            phx-click={JS.navigate(~p"/auth/github")}
            data-testid="button-signin-github"
          >
            Sign in with GitHub
          </.social_button>
          <.social_button
            provider="google"
            phx-click={JS.navigate(~p"/auth/google")}
            data-testid="button-signin-google"
          >
            Sign in with Google
          </.social_button>
        </:actions>
      </.simple_form>
    </Layouts.auth>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
