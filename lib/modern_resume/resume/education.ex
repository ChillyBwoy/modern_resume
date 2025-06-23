defmodule ModernResume.Resume.Education do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  embedded_schema do
    field :degree, :string
    field :description, :string
    field :field_of_study, :string
    field :institution, :string
    field :location, :string
    field :date_start_year, :integer
    field :date_start_month, :integer
    field :date_end_year, :integer
    field :date_end_month, :integer
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
      :date_start_year,
      :date_start_month,
      :date_end_year,
      :date_end_month
    ])
    |> validate_required([:institution, :date_start_year, :date_start_month])
    |> Validation.validate_latex_chars([
      :institution,
      :location,
      :degree,
      :field_of_study,
      :description
    ])
  end
end
