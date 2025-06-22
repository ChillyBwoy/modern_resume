defmodule ModernResume.Resume.Experience do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation
  alias ModernResume.Resume.ExperienceDetail

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
    field :date_start, :date
    field :date_end, :date
    field :employment_type, Ecto.Enum, values: @employment_types

    embeds_many :details, ExperienceDetail, on_replace: :delete
  end

  @doc false
  def changeset(experience, attrs) do
    experience
    |> cast(attrs, [
      :title,
      :description,
      :location,
      :date_start,
      :date_end,
      :employment_type,
      :organization
    ])
    |> validate_required([:title, :date_start])
    |> Validation.validate_latex_chars([
      :title,
      :description,
      :location,
      :organization
    ])
  end

  def employment_types do
    Enum.map(@employment_types, fn item ->
      {display_employment_type(item), item}
    end)
  end

  def display_employment_type(:part_time), do: "Part-time"
  def display_employment_type(:permanent), do: "Permanent"
  def display_employment_type(:self_employed), do: "Self-employed"
  def display_employment_type(:freelance), do: "Freelance"
  def display_employment_type(:contract), do: "Contract"
  def display_employment_type(:internship), do: "Internship"
  def display_employment_type(:apprenticeship), do: "Apprenticeship"
  def display_employment_type(:indirect_contract), do: "Indirect contract"
  def display_employment_type(_), do: raise("Unknown Employment Type")
end
