defmodule ModernResume.Resume do
  @moduledoc """
  The Resume context.
  """
  import ModernResume.Guards

  import Ecto.Query, warn: false
  import ModernResume.Guards

  alias ModernResume.Accounts.User
  alias ModernResume.Repo
  alias ModernResume.Resume.CV
  alias ModernResume.Resume.Content
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
    query = from cv in CV, where: cv.user_id == ^user.id
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

  def add_skill(%CV{} = cv, %{title: _, description: _} = params) do
    case Skill.changeset(%Skill{}, params) |> Ecto.Changeset.apply_action(:create) do
      {:ok, skill} ->
        content =
          cv.content
          |> Content.changeset(%{})
          |> Ecto.Changeset.put_embed(:skills, cv.content.skills ++ [skill])

        cv
        |> CV.changeset(%{})
        |> Ecto.Changeset.put_embed(:content, content)
        |> Repo.update()

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def add_skill(_, _), do: raise("Invalid skill params")

  def update_skill(%CV{} = cv, id, %{title: _, description: _} = attrs) when is_uuid(id) do
    with %Skill{} = skill <- Enum.find(cv.content.skills, &(&1.id == id)),
         {:ok, _} <- Skill.changeset(skill, attrs) |> Ecto.Changeset.apply_action(:update) do
      updated_skills =
        Enum.map(cv.content.skills, fn item ->
          if item.id == id do
            Skill.changeset(%Skill{}, attrs)
          else
            item
          end
        end)

      content =
        cv.content
        |> Content.changeset(%{})
        |> Ecto.Changeset.put_embed(:skills, updated_skills)

      cv
      |> CV.changeset(%{})
      |> Ecto.Changeset.put_embed(:content, content)
      |> Repo.update()
    else
      nil -> raise("No skill found")
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end
end
