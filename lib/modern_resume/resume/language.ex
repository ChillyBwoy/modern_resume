defmodule ModernResume.Resume.Language do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  @fluency_types [
    :elementary,
    :limited,
    :minimum,
    :full,
    :native
  ]

  embedded_schema do
    field :name, :string
    field :fluency, Ecto.Enum, values: @fluency_types
  end

  @doc false
  def changeset(language \\ %__MODULE__{}, attrs \\ %{}) do
    language
    |> cast(attrs, [:name, :fluency])
    |> validate_required([:name, :fluency])
    |> validate_length(:name, min: 1)
    |> Validation.validate_latex_chars([:name])
  end

  def fluency_types do
    Enum.map(@fluency_types, fn item ->
      {display_fluency(item), item}
    end)
  end

  def display_fluency(:elementary), do: "Elementary Proficiency"
  def display_fluency(:limited), do: "Limited Working Proficiency"
  def display_fluency(:minimum), do: "Minimum Professional Proficiency"
  def display_fluency(:full), do: "Full Professional Proficiency"
  def display_fluency(:native), do: "Native or Bilingual Proficiency"
  def display_fluency(_), do: ""
end
