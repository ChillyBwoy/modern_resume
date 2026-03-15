defmodule ModernResume.Resume.Content do
  @moduledoc """
  CV content schema
  """
  use Ecto.Schema

  alias Ecto.Changeset

  alias ModernResume.Resume.Education
  alias ModernResume.Resume.Experience
  alias ModernResume.Resume.Language
  alias ModernResume.Resume.Settings
  alias ModernResume.Resume.Skill
  alias ModernResume.Resume.SocialNetwork
  alias ModernResume.Validation

  @type t :: %__MODULE__{
          name: String.t(),
          position: String.t(),
          email: String.t() | nil,
          phone: String.t() | nil,
          birthdate: Date.t() | nil,
          location: String.t() | nil,
          settings: Settings.t(),
          social_networks: list(SocialNetwork.t()),
          skills: list(Skill.t()),
          experiences: list(Experience.t()),
          educations: list(Education.t()),
          languages: list(Language.t())
        }

  @primary_key false
  embedded_schema do
    field :name, :string
    field :position, :string
    field :email, :string
    field :phone, :string
    field :birthdate, :date
    field :location, :string

    embeds_one :settings, Settings,
      on_replace: :delete,
      defaults_to_struct: true

    embeds_many :social_networks, SocialNetwork, on_replace: :delete
    embeds_many :skills, Skill, on_replace: :delete
    embeds_many :experiences, Experience, on_replace: :delete
    embeds_many :educations, Education, on_replace: :delete
    embeds_many :languages, Language, on_replace: :delete
  end

  @spec changeset(t() | %__MODULE__{}, map()) :: Changeset.t(t())
  def changeset(%__MODULE__{} = content, attrs \\ %{}) do
    content
    |> Changeset.cast(attrs, [:name, :position, :email, :phone, :birthdate, :location])
    |> Changeset.validate_required([:name, :position])
    |> Validation.validate_latex_chars([:name, :position, :email, :location])
    |> Changeset.validate_format(:email, ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,63}$/,
      message: "invalid email format"
    )
    |> Changeset.validate_length(:email, min: 6, max: 320)
    |> Changeset.validate_length(:name, max: 50)
    |> Changeset.validate_length(:position, max: 100)
    |> Changeset.validate_length(:phone, max: 15)
    |> Changeset.validate_length(:location, max: 50)
    |> Changeset.cast_embed(:settings)
    |> Changeset.cast_embed(:social_networks)
    |> Changeset.cast_embed(:skills)
    |> Changeset.cast_embed(:experiences)
    |> Changeset.cast_embed(:educations)
    |> Changeset.cast_embed(:languages)
  end
end
