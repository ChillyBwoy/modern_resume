defmodule Mix.Tasks.Users.Create do
  use Mix.Task

  alias ModernResume.Accounts

  def run(args) do
    Mix.Task.run("app.start")

    with {:ok, {email, password}} <- get_credentials(args),
         {:ok, user} <- Accounts.register_user(%{email: email, password: password}) do
      Mix.shell().info("User Created: #{user.id}")
    else
      {:error, reason} ->
        Mix.shell().error(reason)
    end
  end

  defp get_credentials(args) do
    case args do
      [email, password] when is_binary(email) and is_binary(password) ->
        {:ok, {email, password}}

      [_] ->
        {:error, "No password specified"}

      _ ->
        {:error, "Invalid user data"}
    end
  end
end
