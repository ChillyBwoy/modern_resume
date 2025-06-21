defmodule ModernResume.Resume do
  @moduledoc """
  The Resume context.
  """

  import Ecto.Query, warn: false
  # import ModernResume.Guards

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

  @doc """
  Gets a single cv.

  Raises `Ecto.NoResultsError` if the Cv does not exist.

  ## Examples

      iex> get_cv!(123)
      %CV{}

      iex> get_cv!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cv!(id), do: Repo.get!(CV, id)

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
    skills = cv.content.skills ++ [Skill.changeset(%Skill{}, params)]

    content =
      cv.content
      |> Content.changeset(%{})
      |> Ecto.Changeset.put_embed(:skills, skills)

    cv
    |> CV.changeset(%{})
    |> Ecto.Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  def add_skill(_, _), do: raise("Invalid skill params")

  # def update_skill(%CV{} = cv, id, attrs) when is_uuid(id) and is_map(attrs) do
  #   skills =
  #     cv.content.skills
  #     |> Enum.map(fn skill ->
  #       case skill.id do
  #         ^id ->
  #           Skill.changeset(skill, attrs)

  #         _ ->
  #           skill
  #       end
  #     end)
  # end
end
