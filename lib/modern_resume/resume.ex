defmodule ModernResume.Resume do
  @moduledoc """
  The Resume context.
  """
  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias Ecto.UUID

  alias ModernResume.Repo

  alias ModernResume.Accounts.User
  alias ModernResume.Resume.Content
  alias ModernResume.Resume.CV
  alias ModernResume.Resume.Education
  alias ModernResume.Resume.Experience
  alias ModernResume.Resume.ExperienceDetail
  alias ModernResume.Resume.Language
  alias ModernResume.Resume.Skill
  alias ModernResume.Resume.SocialNetwork

  @spec list_cvs :: [CV.t()]
  def list_cvs do
    Repo.all(CV)
  end

  @spec list_cvs_for(User.t()) :: [CV.t()]
  def list_cvs_for(%User{} = user) do
    query = from(cv in CV, where: cv.user_id == ^user.id, order_by: [desc: cv.updated_at])
    Repo.all(query)
  end

  @spec get_cv(UUID.t()) :: CV.t() | nil
  def get_cv(id) do
    Repo.get(CV, id)
  end

  @spec get_cv_for(User.t(), UUID.t()) :: CV.t() | nil
  def get_cv_for(%User{} = user, cv_id) do
    from(cv in CV, where: cv.user_id == ^user.id) |> Repo.get(cv_id)
  end

  @spec create_cv(map) :: {:ok, CV.t()} | {:error, Ecto.Changeset.t()}
  def create_cv(attrs \\ %{}) do
    %CV{}
    |> CV.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_cv(CV.t(), map) :: {:ok, CV.t()} | {:error, Ecto.Changeset.t()}
  def update_cv(%CV{} = cv, attrs) do
    cv
    |> CV.changeset(attrs)
    |> Repo.update()
  end

  def update_cv(%Changeset{} = changeset) do
    Repo.update(changeset)
  end

  @spec delete_cv(User.t(), UUID.t()) :: {:ok, CV.t()} | {:error, :not_found}
  def delete_cv(%User{} = user, cv_id) do
    case get_cv_for(user, cv_id) do
      %CV{} = cv ->
        Repo.delete(cv)

      _ ->
        {:error, :not_found}
    end
  end

  @spec duplicate_cv(User.t(), UUID.t()) :: {:ok, CV.t()} | {:error, :not_found}
  def duplicate_cv(%User{} = user, cv_id) do
    case get_cv_for(user, cv_id) do
      %CV{} = cv ->
        %CV{}
        |> CV.changeset(%{
          title: "#{cv.title} (copy)",
          user_id: cv.user_id
        })
        |> Changeset.put_change(:content, cv.content)
        |> Repo.insert()

      _ ->
        {:error, :not_found}
    end
  end

  @spec add_entity(CV.t(), atom(), Ecto.Changeset.t()) ::
          {:ok, CV.t()} | {:error, Ecto.Changeset.t()}
  def add_entity(%CV{} = cv, key, new_entity) when is_atom(key) do
    changeset = CV.changeset(cv)

    content = Changeset.get_embed(changeset, :content)
    entities = Changeset.get_embed(content, key)
    content = Changeset.put_embed(content, key, entities ++ [new_entity])

    changeset
    |> Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  @spec add_entity(CV.t(), atom) :: {:ok, CV.t()} | {:error, Ecto.Changeset.t()}
  def add_entity(%CV{} = cv, :skills),
    do: add_entity(cv, :skills, Skill.changeset(%Skill{}))

  def add_entity(%CV{} = cv, :educations),
    do: add_entity(cv, :educations, Education.changeset(%Education{}))

  def add_entity(%CV{} = cv, :languages),
    do: add_entity(cv, :languages, Language.changeset(%Language{}))

  def add_entity(%CV{} = cv, :experiences),
    do: add_entity(cv, :experiences, Experience.changeset(%Experience{}))

  def add_entity(%CV{} = cv, :social_networks),
    do: add_entity(cv, :social_networks, SocialNetwork.changeset(%SocialNetwork{}))

  def add_entity(_, _), do: raise("Can not add an invalid entity")

  @spec sort_entities(CV.t(), atom(), [UUID.t()]) :: {:ok, CV.t()} | {:error, Ecto.Changeset.t()}
  def sort_entities(%CV{} = cv, key, ordered_ids) when is_atom(key) and is_list(ordered_ids) do
    {:ok, entities} = Map.fetch(cv.content, key)

    entities_map =
      entities
      |> Enum.map(&{&1.id, &1})
      |> Map.new()

    new_entities = Enum.map(ordered_ids, &Map.fetch!(entities_map, &1))

    content =
      cv.content
      |> Content.changeset()
      |> Changeset.put_embed(key, new_entities)

    cv
    |> CV.changeset()
    |> Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  @spec delete_entity(CV.t(), atom(), UUID.t()) :: {:ok, CV.t()} | {:error, Ecto.Changeset.t()}
  def delete_entity(%CV{} = cv, key, id) when is_atom(key) do
    {:ok, entities} = Map.fetch(cv.content, key)
    new_entities = Enum.filter(entities, &(&1.id != id))

    content =
      cv.content
      |> Content.changeset()
      |> Changeset.put_embed(key, new_entities)

    cv
    |> CV.changeset()
    |> Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  @spec add_nested_entity(Ecto.Changeset.t(), {atom(), atom()}, UUID.t()) :: Ecto.Changeset.t()
  def add_nested_entity(%Changeset{} = changeset, {parent_key, child_key}, parent_id) do
    content = Changeset.get_embed(changeset, :content)
    new_entity = get_child_changeset({parent_key, child_key})

    entities =
      Changeset.get_embed(content, parent_key)
      |> Enum.map(fn entity ->
        if entity.data.id == parent_id do
          target_list = Changeset.get_embed(entity, child_key)
          Changeset.put_embed(entity, child_key, target_list ++ [new_entity])
        else
          entity
        end
      end)

    content = Changeset.put_embed(content, parent_key, entities)
    Changeset.put_embed(changeset, :content, content)
  end

  @spec delete_nested_entity(CV.t(), {atom(), atom()}, UUID.t()) ::
          {:ok, CV.t()} | {:error, Ecto.Changeset.t()}
  def delete_nested_entity(%CV{} = cv, {parent_key, child_key}, child_id) do
    {:ok, parent_entities} = Map.fetch(cv.content, parent_key)

    new_parent_entities =
      parent_entities
      |> Enum.map(fn parent ->
        {:ok, children} = Map.fetch(parent, child_key)
        new_children = children |> Enum.filter(&(&1.id != child_id))

        parent
        |> get_parent_changeset(parent_key)
        |> Changeset.put_embed(child_key, new_children)
      end)

    content =
      cv.content
      |> Content.changeset()
      |> Changeset.put_embed(parent_key, new_parent_entities)

    cv
    |> CV.changeset()
    |> Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  @spec sort_nested_entities(CV.t(), {atom(), atom()}, UUID.t(), [UUID.t()]) ::
          {:ok, CV.t()} | {:error, Ecto.Changeset.t()}
  def sort_nested_entities(%CV{} = cv, {parent_key, child_key}, parent_id, ordered_ids)
      when is_list(ordered_ids) do
    {:ok, parent_entities} = Map.fetch(cv.content, parent_key)

    new_parent_entities =
      Enum.map(
        parent_entities,
        &map_parent_entity(&1, parent_key, child_key, parent_id, ordered_ids)
      )

    content =
      cv.content
      |> Content.changeset()
      |> Changeset.put_embed(parent_key, new_parent_entities)

    cv
    |> CV.changeset()
    |> Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  defp map_parent_entity(entity, parent_key, child_key, parent_id, ordered_ids) do
    if entity.id == parent_id do
      {:ok, children} = Map.fetch(entity, child_key)
      children_map = Enum.map(children, &{&1.id, &1}) |> Map.new()

      sorted_children =
        Enum.map(ordered_ids, fn id ->
          Map.fetch!(children_map, id)
        end)

      entity
      |> get_parent_changeset(parent_key)
      |> Changeset.put_embed(child_key, sorted_children)
    else
      entity
    end
  end

  defp get_child_changeset({:experiences, :details}),
    do: ExperienceDetail.changeset(%ExperienceDetail{})

  defp get_parent_changeset(exp, :experiences), do: Experience.changeset(exp)
end
