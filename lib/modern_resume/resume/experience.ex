defmodule ModernResume.Resume.Experience do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation
  alias ModernResume.Resume.ExperienceDetail

  embedded_schema do
    field :description, :string
    field :title, :string
    field :location, :string
    field :organization, :string
    field :date_start, :date
    field :date_end, :date

    embeds_many :details, ExperienceDetail, on_replace: :delete

    field :employment_type, Ecto.Enum,
      values: [
        :part_time,
        :permanent,
        :self_employed,
        :freelance,
        :contract,
        :internship,
        :apprenticeship,
        :indirect_contract
      ]
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
      :employment_type,
      :organization
    ])
  end
end
