defmodule ModernResume.Resume.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  @primary_key false
  embedded_schema do
    field :description, :string
    field :title, :string
    field :sort_order, :integer
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:title, :description, :sort_order])
    |> validate_required([:title, :description])
    |> Validation.validate_latex_chars([:title, :description])
  end
end
