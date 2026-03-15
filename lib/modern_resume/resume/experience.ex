defmodule ModernResume.Resume.Experience do
  @moduledoc """
  Experience section schema
  """
  use Ecto.Schema

  alias Ecto.Changeset

  alias ModernResume.Resume.ExperienceDetail
  alias ModernResume.Validation

  @type employment_type ::
          :part_time
          | :permanent
          | :self_employed
          | :freelance
          | :contract
          | :internship
          | :apprenticeship
          | :indirect_contract
  @type t :: %__MODULE__{
          title: String.t(),
          description: String.t(),
          location: String.t(),
          organization: String.t(),
          date_start_month: integer(),
          date_start_year: integer(),
          date_end_month: integer() | nil,
          date_end_year: integer() | nil,
          employment_type: employment_type() | nil,
          details: list(ExperienceDetail.t())
        }

  @employment_types [
    :part_time,
    :permanent,
    :self_employed,
    :freelance,
    :contract,
    :internship,
    :apprenticeship,
    :indirect_contract
  ]

  embedded_schema do
    field :title, :string
    field :description, :string
    field :location, :string
    field :organization, :string
    field :date_start_month, :integer
    field :date_start_year, :integer
    field :date_end_month, :integer
    field :date_end_year, :integer
    field :employment_type, Ecto.Enum, values: @employment_types

    embeds_many :details, ExperienceDetail, on_replace: :delete
  end

  @spec changeset(t() | %__MODULE__{}, map()) :: Changeset.t(t())
  def changeset(%__MODULE__{} = experience, attrs \\ %{}) do
    experience
    |> Changeset.cast(attrs, [
      :title,
      :description,
      :location,
      :date_start_month,
      :date_start_year,
      :date_end_month,
      :date_end_year,
      :employment_type,
      :organization
    ])
    |> Changeset.cast_embed(:details)
    |> Changeset.validate_required([:title, :date_start_month, :date_start_year])
    |> Changeset.validate_length(:title, max: 100)
    |> Changeset.validate_length(:description, max: 500)
    |> Changeset.validate_length(:location, max: 100)
    |> Changeset.validate_length(:organization, max: 100)
    |> Validation.validate_latex_chars([
      :title,
      :description,
      :location,
      :organization
    ])
  end

  @spec employment_types :: list({String.t(), employment_type()})
  def employment_types, do: Enum.map(@employment_types, &{display_employment_type(&1), &1})

  @spec display_employment_type(employment_type()) :: String.t()
  def display_employment_type(:part_time), do: "Part-time"
  def display_employment_type(:permanent), do: "Permanent"
  def display_employment_type(:self_employed), do: "Self-employed"
  def display_employment_type(:freelance), do: "Freelance"
  def display_employment_type(:contract), do: "Contract"
  def display_employment_type(:internship), do: "Internship"
  def display_employment_type(:apprenticeship), do: "Apprenticeship"
  def display_employment_type(:indirect_contract), do: "Indirect contract"
  def display_employment_type(_), do: ""
end
