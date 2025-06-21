defmodule ModernResume.Repo do
  use Ecto.Repo,
    otp_app: :modern_resume,
    adapter: Ecto.Adapters.Postgres
end
