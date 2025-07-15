defmodule ModernResume.Resume.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  embedded_schema do
    field :header, :string
    field :title, :string
    field :description, :string
  end

  @doc false
  def changeset(skill \\ %__MODULE__{}, attrs \\ %{}) do
    skill
    |> cast(attrs, [:header, :title, :description])
    |> validate_required([:title, :description])
    |> validate_length(:header, max: 100)
    |> validate_length(:title, max: 100)
    |> validate_length(:description, max: 500)
    |> Validation.validate_latex_chars([:header, :title, :description])
  end
end
