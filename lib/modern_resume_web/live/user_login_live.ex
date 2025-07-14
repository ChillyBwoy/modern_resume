defmodule ModernResumeWeb.UserLoginLive do
  use ModernResumeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto w-sm flex flex-col gap-4">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />

        <:actions>
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
          <.button
            type="button"
            class="w-full"
            variant={:default}
            phx-click={JS.navigate(~p"/auth/github")}
          >
            Log in with GitHub
          </.button>
          <.button
            type="button"
            class="w-full"
            variant={:default}
            phx-click={JS.navigate(~p"/auth/google")}
          >
            Log in with Google
          </.button>
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
