defmodule ModernResume.Resume.Education do
  @moduledoc """
  Education section schema
  """
  use Ecto.Schema

  alias Ecto.Changeset

  alias ModernResume.Validation

  @type t :: %__MODULE__{
          degree: String.t() | nil,
          description: String.t() | nil,
          field_of_study: String.t() | nil,
          institution: String.t(),
          location: String.t() | nil,
          date_start_year: integer(),
          date_start_month: integer(),
          date_end_year: integer() | nil,
          date_end_month: integer() | nil
        }

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

  @spec changeset(t() | %__MODULE__{}, map()) :: Changeset.t(t())
  def changeset(%__MODULE__{} = education, attrs \\ %{}) do
    education
    |> Changeset.cast(attrs, [
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
    |> Changeset.validate_required([:institution, :date_start_year, :date_start_month])
    |> Changeset.validate_length(:degree, max: 100)
    |> Changeset.validate_length(:institution, max: 100)
    |> Changeset.validate_length(:location, max: 100)
    |> Changeset.validate_length(:field_of_study, max: 100)
    |> Changeset.validate_length(:description, max: 1000)
    |> Validation.validate_latex_chars([
      :institution,
      :location,
      :degree,
      :field_of_study,
      :description
    ])
  end
end
