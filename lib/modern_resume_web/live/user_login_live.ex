defmodule ModernResumeWeb.UserLoginLive do
  use ModernResumeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto w-sm flex flex-col gap-4">
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
        <.form_field field={@form[:email]}>
          <:label>Email</:label>
          <.input field={@form[:email]} type="email" required />
        </.form_field>

        <.form_field field={@form[:password]}>
          <:label>Password</:label>
          <.input field={@form[:password]} type="password" required />
        </.form_field>

        <.form_field field={@form[:remember_me]}>
          <:label>Keep me logged in</:label>
          <.input field={@form[:remember_me]} type="checkbox" />
        </.form_field>

        <:actions>
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full" data-testid="signin_button">
            Sign in
          </.button>
          <.social_button
            provider="github"
            url={~p"/auth/github"}
            label="Sign in with GitHub"
            data-testid="signin_github"
          />
          <.social_button
            provider="google"
            url={~p"/auth/google"}
            label="Sign in with Google"
            data-testid="signin_google"
          />
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
