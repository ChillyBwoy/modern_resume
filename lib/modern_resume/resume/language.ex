defmodule ModernResume.Resume.Language do
  @moduledoc """
  Language section schema
  """
  use Ecto.Schema

  alias Ecto.Changeset

  alias ModernResume.Validation

  @type fluency_type :: :elementary | :limited | :minimum | :full | :native
  @type t :: %__MODULE__{
          name: String.t(),
          fluency: fluency_type()
        }

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

  @spec changeset(t() | %__MODULE__{}, map()) :: Changeset.t(t())
  def changeset(%__MODULE__{} = language, attrs \\ %{}) do
    language
    |> Changeset.cast(attrs, [:name, :fluency])
    |> Changeset.validate_required([:name, :fluency])
    |> Changeset.validate_length(:name, min: 1, max: 50)
    |> Validation.validate_latex_chars([:name])
  end

  @spec fluency_types :: list({String.t(), fluency_type()})
  def fluency_types, do: Enum.map(@fluency_types, &{display_fluency(&1), &1})

  @spec display_fluency(fluency_type()) :: String.t()
  def display_fluency(:elementary), do: "Elementary Proficiency"
  def display_fluency(:limited), do: "Limited Working Proficiency"
  def display_fluency(:minimum), do: "Minimum Professional Proficiency"
  def display_fluency(:full), do: "Full Professional Proficiency"
  def display_fluency(:native), do: "Native or Bilingual Proficiency"
  def display_fluency(_), do: ""
end
