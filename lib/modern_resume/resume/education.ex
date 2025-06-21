defmodule ModernResume.Resume.Education do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  @primary_key false
  embedded_schema do
    field :description, :string
    field :degree, :string
    field :field_of_study, :string
    field :institution, :string
    field :location, :string
    field :date_start, :date
    field :date_end, :date
    field :sort_order, :integer
  end

  @doc false
  def changeset(education, attrs) do
    education
    |> cast(attrs, [
      :institution,
      :location,
      :degree,
      :field_of_study,
      :description,
      :date_start,
      :date_end,
      :sort_order
    ])
    |> validate_required([
      :institution,
      :date_start
    ])
    |> Validation.validate_latex_chars([
      :institution,
      :location,
      :degree,
      :field_of_study,
      :description
    ])
  end
end
