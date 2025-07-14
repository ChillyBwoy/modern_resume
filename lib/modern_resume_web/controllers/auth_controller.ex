defmodule ModernResumeWeb.AuthController do
  use ModernResumeWeb, :controller

  alias Ueberauth.Strategy.Helpers

  alias ModernResume.Accounts
  alias ModernResume.Accounts.User

  alias ModernResumeWeb.UserAuth

  plug Ueberauth

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Bye Bye")
    |> clear_session()
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_failure: _}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case get_or_create_user(auth) do
      {:ok, %User{} = user} ->
        conn
        |> put_flash(:info, "Welcome!")
        |> UserAuth.log_in_user(user)

      {:error, _} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: ~p"/")
    end
  end

  defp get_or_create_user(%{provider: :github, info: %{email: email}}) do
    Accounts.get_or_create(email)
  end
end
