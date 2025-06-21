defmodule ModernResume.Resume do
  @moduledoc """
  The Resume context.
  """

  import Ecto.Query, warn: false
  alias ModernResume.Repo

  alias ModernResume.Resume.CV

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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cv changes.

  ## Examples

      iex> change_cv(cv)
      %Ecto.Changeset{data: %CV{}}

  """
  def change_cv(%CV{} = cv, attrs \\ %{}) do
    CV.changeset(cv, attrs)
  end
end
