defmodule ModernResume.Resume.CV do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cvs" do
    field :title, :string
    embeds_one :content, ModernResume.Resume.Content, on_replace: :delete

    belongs_to :user, ModernResume.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cv \\ %__MODULE__{}, attrs \\ %{}) do
    cv
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
    |> validate_length(:title, max: 100)
    |> cast_embed(:content)
  end
end
