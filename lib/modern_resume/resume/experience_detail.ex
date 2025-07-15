defmodule ModernResume.Resume.ExperienceDetail do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  embedded_schema do
    field :title, :string
    field :content, :string
  end

  @doc false
  def changeset(experience_detail \\ %__MODULE__{}, attrs \\ %{}) do
    experience_detail
    |> cast(attrs, [:title, :content])
    |> validate_required([:content])
    |> validate_length(:title, max: 50)
    |> validate_length(:content, max: 500)
    |> Validation.validate_latex_chars([:title, :content])
  end
end
