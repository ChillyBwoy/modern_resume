defmodule ModernResume.Resume.ExperienceDetail do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  @primary_key false
  embedded_schema do
    field :content, :string
    field :sort_order, :integer
  end

  @doc false
  def changeset(experience_detail, attrs) do
    experience_detail
    |> cast(attrs, [:content, :sort_order, :experience_id])
    |> validate_required([:content, :experience_id])
    |> Validation.validate_latex_chars([:content])
  end
end
