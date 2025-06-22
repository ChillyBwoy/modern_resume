defmodule ModernResumeWeb.CV.FormList.EntityController do
  @type entity :: term()
  @type state :: map()
  @type params :: map()

  @callback get_list(state) :: [entity]

  @callback sort_list(ids :: list()) :: any()

  @callback create_changeset(state) :: Ecto.Changeset.t()

  @callback create_entity(params, state) ::
              {:ok, entity} | {:error, reason :: Ecto.Changeset.t()}

  @callback change_entity(entity, state) :: Ecto.Changeset.t()

  @callback delete_entity(entity) :: {:ok, entity}

  @callback update_entity(entity, params) ::
              {:ok, entity :: term()}
              | {:error, reason :: Ecto.Changeset.t()}
              | {:nochanges, entity}
end
