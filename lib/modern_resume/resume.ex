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

  def list_cvs do
    Repo.all(CV)
  end

  def list_cvs_for(%User{} = user) do
    query = from(cv in CV, where: cv.user_id == ^user.id)
    Repo.all(query)
  end

  def get_cv(id) when is_uuid(id) do
    Repo.get!(CV, id)
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

  def add_entity(%Ecto.Changeset{} = changeset, key, new_entity) when is_atom(key) do
    content = Ecto.Changeset.get_embed(changeset, :content)
    entities = Ecto.Changeset.get_embed(content, key)
    content = Ecto.Changeset.put_embed(content, key, entities ++ [new_entity])
    Ecto.Changeset.put_embed(changeset, :content, content)
  end

  def add_entity(changeset, :skills),
    do: add_entity(changeset, :skills, Skill.changeset())

  def add_entity(changeset, :educations),
    do: add_entity(changeset, :educations, Education.changeset())

  def add_entity(changeset, :languages),
    do: add_entity(changeset, :languages, Language.changeset())

  def add_entity(changeset, :experiences),
    do: add_entity(changeset, :experiences, Experience.changeset())

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

  def add_nested_entity(%Ecto.Changeset{} = changeset, {parent_key, child_key}, src_id) do
    content = Ecto.Changeset.get_embed(changeset, :content)
    new_entity = get_nested_child_changeset({parent_key, child_key})

    entities =
      Ecto.Changeset.get_embed(content, parent_key)
      |> Enum.map(fn entity ->
        if entity.data.id == src_id do
          target_list = Ecto.Changeset.get_embed(entity, child_key)
          Ecto.Changeset.put_embed(entity, child_key, target_list ++ [new_entity])
        else
          entity
        end
      end)

    content = Ecto.Changeset.put_embed(content, parent_key, entities)
    Ecto.Changeset.put_embed(changeset, :content, content)
  end

  def delete_nested_entity(%CV{} = cv, {parent_key, child_key}, id) when is_uuid(id) do
    {:ok, entities} = Map.fetch(cv.content, parent_key)

    new_entities =
      entities
      |> Enum.map(fn entity ->
        {:ok, nested_entities} = Map.fetch(entity, child_key)
        new_nested_entities = nested_entities |> Enum.filter(&(&1.id != id))

        entity
        |> get_nested_parent_changeset(parent_key)
        |> Ecto.Changeset.put_embed(child_key, new_nested_entities)
      end)

    content =
      cv.content
      |> Content.changeset()
      |> Ecto.Changeset.put_embed(parent_key, new_entities)

    cv
    |> CV.changeset(%{})
    |> Ecto.Changeset.put_embed(:content, content)
    |> Repo.update()
  end

  defp get_nested_child_changeset({:experiences, :details}), do: ExperienceDetail.changeset()

  defp get_nested_parent_changeset(exp, :experiences), do: Experience.changeset(exp)
end
