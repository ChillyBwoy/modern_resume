defmodule ModernResume.Resume.Content do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_many :skills, ModernResume.Resume.Skill, on_replace: :delete
    embeds_many :experiences, ModernResume.Resume.Experience, on_replace: :delete
    embeds_many :educations, ModernResume.Resume.Education, on_replace: :delete
    embeds_many :languages, ModernResume.Resume.Language, on_replace: :delete
  end

  def changeset(content, attrs) do
    content
    |> cast(attrs, [])
    |> cast_embed(:skills)
    |> cast_embed(:experiences)
    |> cast_embed(:educations)
    |> cast_embed(:languages)
  end
end
