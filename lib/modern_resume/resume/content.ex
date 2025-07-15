defmodule ModernResume.Resume.Content do
  use Ecto.Schema
  import Ecto.Changeset

  alias ModernResume.Validation

  @primary_key false
  embedded_schema do
    field :name, :string
    field :position, :string
    field :email, :string
    field :phone, :string
    field :birthdate, :date
    field :location, :string

    embeds_one :settings, ModernResume.Resume.Settings, on_replace: :delete

    embeds_many :social_networks, ModernResume.Resume.SocialNetwork, on_replace: :delete
    embeds_many :skills, ModernResume.Resume.Skill, on_replace: :delete
    embeds_many :experiences, ModernResume.Resume.Experience, on_replace: :delete
    embeds_many :educations, ModernResume.Resume.Education, on_replace: :delete
    embeds_many :languages, ModernResume.Resume.Language, on_replace: :delete
  end

  def changeset(content \\ %__MODULE__{}, attrs \\ %{}) do
    content
    |> cast(attrs, [:name, :position, :email, :phone, :birthdate, :location])
    |> validate_required([:name, :position])
    |> Validation.validate_latex_chars([:name, :position, :email, :location])
    |> validate_length(:name, max: 50)
    |> validate_length(:email, max: 100)
    |> validate_length(:position, max: 100)
    |> validate_length(:phone, max: 15)
    |> validate_length(:location, max: 50)
    |> cast_embed(:settings)
    |> cast_embed(:social_networks)
    |> cast_embed(:skills)
    |> cast_embed(:experiences)
    |> cast_embed(:educations)
    |> cast_embed(:languages)
  end
end
