defmodule ModernResume.Resume.ExperienceDetail do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  embedded_schema do
    field :content, :string
  end

  @doc false
  def changeset(experience_detail, attrs) do
    experience_detail
    |> cast(attrs, [:content])
    |> validate_required([:content])
    |> Validation.validate_latex_chars([:content])
  end
end
