defmodule ModernResume.Resume.CV do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cvs" do
    field :title, :string
    embeds_one :content, ModernResume.Resume.Content, on_replace: :update

    belongs_to :user, ModernResume.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cv, attrs) do
    cv
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> cast_embed(:content)
  end
end
