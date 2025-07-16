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
  alias ModernResume.Resume.ExperienceDetail
  alias ModernResume.Resume.Language
  alias ModernResume.Resume.Skill
  alias ModernResume.Resume.SocialNetwork

  def list_cvs do
    Repo.all(CV)
  end

  def list_cvs_for(%User{} = user) do
    query = from(cv in CV, where: cv.user_id == ^user.id, order_by: [desc: cv.updated_at])
    Repo.all(query)
  end

  def get_cv(id) when is_uuid(id) do
    Repo.get(CV, id)
  end

  def get_cv_for(%User{} = user, cv_id) when is_uuid(cv_id) do
    from(cv in CV, where: cv.user_id == ^user.id) |> Repo.get(cv_id)
  end

  def create_cv(attrs \\ %{}) do
    %CV{}
    |> CV.changeset(attrs)
    |> Repo.insert()
  end

  def update_cv(%CV{} = cv, attrs) do
    cv
    |> CV.changeset(attrs)
    |> Repo.update()
  end

  def update_cv(%Ecto.Changeset{} = changeset) do
    changeset |> Repo.update()
  end

  def delete_cv(%CV{} = cv) do
    Repo.delete(cv)
  end

  def add_entity(%CV{} = cv, key, new_entity) when is_atom(key) do
    changeset = CV.changeset(cv)

    content = Ecto.Changeset.get_embed(changeset, :content)
    entities = Ecto.Changeset.get_embed(content, key)
    content = Ecto.Changeset.put_embed(content, key, entities ++ [new_entity])

    changeset
    |> Ecto.Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  def add_entity(%CV{} = cv, :skills),
    do: add_entity(cv, :skills, Skill.changeset())

  def add_entity(%CV{} = cv, :educations),
    do: add_entity(cv, :educations, Education.changeset())

  def add_entity(%CV{} = cv, :languages),
    do: add_entity(cv, :languages, Language.changeset())

  def add_entity(%CV{} = cv, :experiences),
    do: add_entity(cv, :experiences, Experience.changeset())

  def add_entity(%CV{} = cv, :social_networks),
    do: add_entity(cv, :social_networks, SocialNetwork.changeset())

  def add_entity(_, _), do: raise("Can not add an invalid entity")

  def sort_entities(%CV{} = cv, key, ordered_ids) when is_atom(key) and is_list(ordered_ids) do
    {:ok, entities} = Map.fetch(cv.content, key)

    if length(entities) != length(ordered_ids) do
      {:error, :invalid_list}
    else
      entities_map = Enum.map(entities, &{&1.id, &1}) |> Map.new()

      new_entities =
        Enum.map(ordered_ids, fn id ->
          Map.fetch!(entities_map, id)
        end)

      content =
        cv.content
        |> Content.changeset()
        |> Ecto.Changeset.put_embed(key, new_entities)

      cv
      |> CV.changeset(%{})
      |> Ecto.Changeset.put_embed(:content, content)
      |> Repo.update()
    end
  end

  def delete_entity(%CV{} = cv, key, id) when is_atom(key) and is_uuid(id) do
    {:ok, entities} = Map.fetch(cv.content, key)
    new_entities = Enum.filter(entities, &(&1.id != id))

    content =
      cv.content
      |> Content.changeset()
      |> Ecto.Changeset.put_embed(key, new_entities)

    cv
    |> CV.changeset(%{})
    |> Ecto.Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  def add_nested_entity(%Ecto.Changeset{} = changeset, {parent_key, child_key}, parent_id) do
    content = Ecto.Changeset.get_embed(changeset, :content)
    new_entity = get_child_changeset({parent_key, child_key})

    entities =
      Ecto.Changeset.get_embed(content, parent_key)
      |> Enum.map(fn entity ->
        if entity.data.id == parent_id do
          target_list = Ecto.Changeset.get_embed(entity, child_key)
          Ecto.Changeset.put_embed(entity, child_key, target_list ++ [new_entity])
        else
          entity
        end
      end)

    content = Ecto.Changeset.put_embed(content, parent_key, entities)
    Ecto.Changeset.put_embed(changeset, :content, content)
  end

  def delete_nested_entity(%CV{} = cv, {parent_key, child_key}, child_id)
      when is_uuid(child_id) do
    {:ok, parent_entities} = Map.fetch(cv.content, parent_key)

    new_parent_entities =
      parent_entities
      |> Enum.map(fn parent ->
        {:ok, children} = Map.fetch(parent, child_key)
        new_children = children |> Enum.filter(&(&1.id != child_id))

        parent
        |> get_parent_changeset(parent_key)
        |> Ecto.Changeset.put_embed(child_key, new_children)
      end)

    content =
      cv.content
      |> Content.changeset()
      |> Ecto.Changeset.put_embed(parent_key, new_parent_entities)

    cv
    |> CV.changeset(%{})
    |> Ecto.Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  def sort_nested_entities(%CV{} = cv, {parent_key, child_key}, parent_id, ordered_ids)
      when is_uuid(parent_id) and is_list(ordered_ids) do
    {:ok, parent_entities} = Map.fetch(cv.content, parent_key)

    new_parent_entities =
      parent_entities
      |> Enum.map(fn parent ->
        if parent.id == parent_id do
          {:ok, children} = Map.fetch(parent, child_key)
          children_map = Enum.map(children, &{&1.id, &1}) |> Map.new()

          sorted_children =
            Enum.map(ordered_ids, fn id ->
              Map.fetch!(children_map, id)
            end)

          parent
          |> get_parent_changeset(parent_key)
          |> Ecto.Changeset.put_embed(child_key, sorted_children)
        else
          parent
        end
      end)

    content =
      cv.content
      |> Content.changeset()
      |> Ecto.Changeset.put_embed(parent_key, new_parent_entities)

    cv
    |> CV.changeset(%{})
    |> Ecto.Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  defp get_child_changeset({:experiences, :details}), do: ExperienceDetail.changeset()

  defp get_parent_changeset(exp, :experiences), do: Experience.changeset(exp)
end
