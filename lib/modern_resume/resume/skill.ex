defmodule ModernResume.Resume.Skill do
  @moduledoc """
  Skill section schema
  """
  use Ecto.Schema

  alias Ecto.Changeset

  alias ModernResume.Validation

  @type t :: %__MODULE__{
          header: String.t() | nil,
          title: String.t(),
          description: String.t()
        }

  embedded_schema do
    field :header, :string
    field :title, :string
    field :description, :string
  end

  @spec changeset(t() | %__MODULE__{}, map()) :: Changeset.t(t())
  def changeset(%__MODULE__{} = skill, attrs \\ %{}) do
    skill
    |> Changeset.cast(attrs, [:header, :title, :description])
    |> Changeset.validate_required([:title, :description])
    |> Changeset.validate_length(:header, max: 100)
    |> Changeset.validate_length(:title, max: 100)
    |> Changeset.validate_length(:description, max: 500)
    |> Validation.validate_latex_chars([:header, :title, :description])
  end
end
