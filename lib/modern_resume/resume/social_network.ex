defmodule ModernResume.Resume.SocialNetwork do
  use Ecto.Schema
  import Ecto.Changeset

  @platforms [
    :github,
    :linkedin,
    :gitlab,
    :arxiv,
    :battlenet,
    :mastodon,
    :bitbucket,
    :googlescholar,
    :matrix,
    :codeberg,
    :inspire,
    :orcid,
    :discord,
    :instagram,
    :researcherid,
    :researchgate,
    :signal,
    :skype,
    :playstation,
    :soundcloud,
    :stackoverflow,
    :tiktok,
    :steam,
    :telegram,
    :twitch,
    :twitter,
    :whatsapp,
    :xbox,
    :xing,
    :youtube
  ]

  embedded_schema do
    field :platform, Ecto.Enum, values: @platforms
    field :content, :string
    field :alias, :string
  end

  def changeset(network \\ %__MODULE__{}, attrs \\ %{}) do
    network
    |> cast(attrs, [:platform, :content, :alias])
    |> validate_required([:platform, :content])
  end

  def platform_choices do
    Enum.map(@platforms, fn item ->
      {item, item}
    end)
  end
end
