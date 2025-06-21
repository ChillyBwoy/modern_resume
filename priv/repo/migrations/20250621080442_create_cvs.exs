defmodule ModernResume.Repo.Migrations.CreateCvs do
  use Ecto.Migration

  def change do
    create table(:cvs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :content, :map
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:cvs, [:user_id])
  end
end
