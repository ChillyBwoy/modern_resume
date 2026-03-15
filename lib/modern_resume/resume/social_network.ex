defmodule ModernResume.Resume.SocialNetwork do
  @moduledoc """
  Social network section schema
  """
  use Ecto.Schema

  alias Ecto.Changeset

  @type platform ::
          :github
          | :linkedin
          | :gitlab
          | :arxiv
          | :battlenet
          | :mastodon
          | :bitbucket
          | :googlescholar
          | :matrix
          | :codeberg
          | :inspire
          | :orcid
          | :discord
          | :instagram
          | :researcherid
          | :researchgate
          | :signal
          | :skype
          | :playstation
          | :soundcloud
          | :stackoverflow
          | :tiktok
          | :steam
          | :telegram
          | :twitch
          | :twitter
          | :whatsapp
          | :xbox
          | :xing
          | :youtube

  @type t :: %__MODULE__{
          platform: platform(),
          content: String.t(),
          alias: String.t() | nil
        }

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

  @spec changeset(t() | %__MODULE__{}, map()) :: Changeset.t(t())
  def changeset(%__MODULE__{} = social_network, attrs \\ %{}) do
    social_network
    |> Changeset.cast(attrs, [:platform, :content, :alias])
    |> Changeset.validate_required([:platform, :content])
    |> Changeset.validate_length(:content, max: 100)
    |> Changeset.validate_length(:alias, max: 100)
  end

  @spec platform_options() :: list({String.t(), platform()})
  def platform_options, do: Enum.map(@platforms, &{"#{&1}", &1})
end
