defmodule ModernResume.Resume do
  @moduledoc """
  The Resume context.
  """
  import ModernResume.Guards

  import Ecto.Query, warn: false
  import ModernResume.Guards

  alias ModernResume.Repo

  alias ModernResume.Accounts.User

  alias ModernResume.Resume.Content
  alias ModernResume.Resume.CV
  alias ModernResume.Resume.Education
  alias ModernResume.Resume.Experience
  alias ModernResume.Resume.Language
  alias ModernResume.Resume.Skill

  @doc """
  Returns the list of cvs.

  ## Examples

      iex> list_cvs()
      [%CV{}, ...]

  """
  def list_cvs do
    Repo.all(CV)
  end

  def list_cvs_for(%User{} = user) do
    query = from(cv in CV, where: cv.user_id == ^user.id)
    Repo.all(query)
  end

  @doc """
  Gets a single cv.

  Raises `Ecto.NoResultsError` if the Cv does not exist.

  ## Examples

      iex> get_cv!(123)
      %CV{}

      iex> get_cv!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cv(id) when is_uuid(id) do
    Repo.get!(CV, id)
  end

  @doc """
  Creates a cv.

  ## Examples

      iex> create_cv(%{field: value})
      {:ok, %CV{}}

      iex> create_cv(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cv(attrs \\ %{}) do
    %CV{}
    |> CV.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cv.

  ## Examples

      iex> update_cv(cv, %{field: new_value})
      {:ok, %CV{}}

      iex> update_cv(cv, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cv(%CV{} = cv, attrs) do
    cv
    |> CV.changeset(attrs)
    |> Repo.update()
  end

  def update_cv(%Ecto.Changeset{} = changeset) do
    changeset |> Repo.update()
  end

  @doc """
  Deletes a cv.

  ## Examples

      iex> delete_cv(cv)
      {:ok, %CV{}}

      iex> delete_cv(cv)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cv(%CV{} = cv) do
    Repo.delete(cv)
  end

  defp add_entity_to_list(%Ecto.Changeset{} = changeset, key, entity) when is_atom(key) do
    content = Ecto.Changeset.get_embed(changeset, :content)
    entities = Ecto.Changeset.get_embed(content, key)
    content = Ecto.Changeset.put_embed(content, key, entities ++ [entity])
    Ecto.Changeset.put_embed(changeset, :content, content)
  end

  @spec add_entity(Ecto.Changeset.t(), :educations | :experiences | :languages | :skills) ::
          Ecto.Changeset.t()
  def add_entity(changeset, :skills),
    do: add_entity_to_list(changeset, :skills, Skill.changeset())

  def add_entity(changeset, :educations),
    do: add_entity_to_list(changeset, :educations, Education.changeset())

  def add_entity(changeset, :languages),
    do: add_entity_to_list(changeset, :languages, Language.changeset())

  def add_entity(changeset, :experiences),
    do: add_entity_to_list(changeset, :experiences, Experience.changeset())

  def sort_entities(%CV{} = cv, key, indexes) when is_atom(key) and is_list(indexes) do
    {:ok, entries} = Map.fetch(cv.content, key)

    new_entries =
      indexes
      |> Enum.map(fn idx ->
        Enum.at(entries, idx)
      end)

    content =
      cv.content
      |> Content.changeset()
      |> Ecto.Changeset.put_embed(key, new_entries)

    cv
    |> CV.changeset(%{})
    |> Ecto.Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  def delete_entity(%CV{} = cv, key, index) when is_atom(key) and is_number(index) do
    {:ok, entries} = Map.fetch(cv.content, key)
    new_entries = entries |> List.delete_at(index)

    content =
      cv.content
      |> Content.changeset()
      |> Ecto.Changeset.put_embed(key, new_entries)

    cv
    |> CV.changeset(%{})
    |> Ecto.Changeset.put_embed(:content, content)
    |> Repo.update()
  end
end
