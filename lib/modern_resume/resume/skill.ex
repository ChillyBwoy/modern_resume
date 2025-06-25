defmodule ModernResume.Resume.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  embedded_schema do
    field :description, :string
    field :title, :string
  end

  @doc false
  def changeset(skill \\ %__MODULE__{}, attrs \\ %{}) do
    skill
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
    |> Validation.validate_latex_chars([:title, :description])
  end
end
