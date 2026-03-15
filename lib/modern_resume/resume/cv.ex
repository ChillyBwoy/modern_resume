defmodule ModernResume.Resume.CV do
  @moduledoc """
  CV schema
  """
  use Ecto.Schema

  alias Ecto.Changeset

  alias ModernResume.Accounts.User
  alias ModernResume.Resume.Content

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          title: String.t(),
          content: Content.t(),
          user_id: Ecto.UUID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cvs" do
    field :title, :string
    embeds_one :content, Content, on_replace: :delete

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t() | %__MODULE__{}, map()) :: Changeset.t(t())
  def changeset(%__MODULE__{} = cv, attrs \\ %{}) do
    cv
    |> Changeset.cast(attrs, [:title, :user_id])
    |> Changeset.validate_required([:title, :user_id])
    |> Changeset.validate_length(:title, max: 100)
    |> Changeset.cast_embed(:content)
  end
end
