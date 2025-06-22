defmodule ModernResumeWeb.CV.FormList.EntityFormList do
  use Phoenix.Component
  alias ModernResumeWeb.CV.FormList.EntityFormList

  @type t :: %__MODULE__{
          entity: Ecto.Schema.t(),
          form: Phoenix.HTML.Form.t()
        }

  @enforce_keys [:entity, :form]
  defstruct [:entity, :form]

  def create(state, controller) do
    controller.get_list(state)
    |> Enum.map(fn item ->
      %EntityFormList{
        entity: item,
        form: controller.change_entity(item, state) |> to_form()
      }
    end)
  end

  def update(form_list, id, %Ecto.Changeset{} = changeset) do
    Enum.map(form_list, fn %EntityFormList{} = item ->
      case item.entity.id do
        ^id -> %EntityFormList{item | form: to_form(changeset)}
        _ -> item
      end
    end)
  end
end
