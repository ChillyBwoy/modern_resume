defmodule ModernResume.Resume.ExperienceDetail do
  @moduledoc """
  Experience detail section schema
  """
  use Ecto.Schema

  alias Ecto.Changeset

  alias ModernResume.Validation

  @type t :: %__MODULE__{
          title: String.t(),
          content: String.t()
        }

  embedded_schema do
    field :title, :string
    field :content, :string
  end

  @spec changeset(t() | %__MODULE__{}, map()) :: Changeset.t(t())
  def changeset(%__MODULE__{} = experience_detail, attrs \\ %{}) do
    experience_detail
    |> Changeset.cast(attrs, [:title, :content])
    |> Changeset.validate_required([:content])
    |> Changeset.validate_length(:title, max: 50)
    |> Changeset.validate_length(:content, max: 500)
    |> Validation.validate_latex_chars([:title, :content])
  end
end
