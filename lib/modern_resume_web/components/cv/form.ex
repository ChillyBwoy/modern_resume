defmodule ModernResumeWeb.CV.Form do
  use Phoenix.Component

  import ModernResumeWeb.CoreComponents

  alias ModernResume.Resume.Language
  alias ModernResume.Resume.Experience

  defp get_date_options(:year) do
    year = Date.utc_today().year

    Range.new(year, year - 100, -1)
    |> Enum.map(&{"#{&1}", "#{&1}"})
  end

  defp get_date_options(:month) do
    1..12
    |> Enum.map(fn month ->
      {Timex.month_name(month), "#{month}"}
    end)
  end

  attr :month, Phoenix.HTML.FormField, required: true
  attr :year, Phoenix.HTML.FormField, required: true

  defp month_picker(assigns) do
    ~H"""
    <div class="grid grid-cols-[2fr_1fr] gap-2">
      <.input
        type="select"
        field={@month}
        label="Month"
        prompt="--"
        options={get_date_options(:month)}
      />
      <.input type="select" field={@year} label="Year" prompt="--" options={get_date_options(:year)} />
    </div>
    """
  end

  attr :on_delete, :string, default: nil
  slot :inner_block, required: true

  defp entity(assigns) do
    ~H"""
    <div class="group relative">
      <div class="flex flex-col gap-4 rounded-lg focus-within:shadow-xl focus-within:ring-1 focus-within:ring-gray-100 relative p-3">
        {render_slot(@inner_block)}
      </div>

      <div
        :if={@on_delete != nil}
        class="absolute opacity-0 group-hover:opacity-100 bottom-full right-0 mb-1 bg-white px-2 py-1 rounded-lg ring-1 ring-gray-100 flex items-center gap-4 pointer-events-auto focus:outline-none"
        tabindex="0"
      >
        <button
          type="button"
          data-confirm="Delete this experience?"
          phx-click={@on_delete}
          tabindex="-1"
          class="flex items-center"
        >
          <.icon name="hero-trash" class="size-4 text-rose-600" />
        </button>
        <span data-type="sort-handle" class="flex items-center">
          <.icon name="hero-bars-3" class="size-4 text-gray-600 cursor-move" />
        </span>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :on_add, :string, default: nil
  slot :inner_block, required: true

  defp fieldset(assigns) do
    ~H"""
    <fieldset class="flex flex-col gap-4">
      <legend class="text-2xl font-bold border-b-2 block py-1">
        {@title}
      </legend>
      {render_slot(@inner_block)}
      <div
        :if={@on_add != nil}
        class="relative flex items-center justify-center before:absolute before:h-px before:bg-gray-200 before:left-0 before:right-0"
      >
        <button
          type="button"
          phx-click={@on_add}
          class="size-8 bg-black rounded-full flex items-center justify-center z-10"
        >
          <.icon name="hero-plus" class="size-6 text-white" />
        </button>
      </div>
    </fieldset>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :index, :integer, required: true

  defp language_form(assigns) do
    ~H"""
    <.entity on_delete="language:delete">
      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:name]} label="Name" phx-debounce="blur" />
        <.input
          type="select"
          field={@form[:fluency]}
          label="Fluency"
          prompt="--"
          options={Language.fluency_types()}
        />
      </div>
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :index, :integer, required: true

  defp education_form(assigns) do
    ~H"""
    <.entity on_delete="education:delete">
      <.input field={@form[:degree]} label="Degree" phx-debounce="blur" />
      <.input field={@form[:institution]} label="Institution" phx-debounce="blur" />
      <.input field={@form[:location]} label="Country, City, etc." phx-debounce="blur" />
      <div class="grid grid-cols-2 gap-4">
        <.month_picker month={@form[:date_start_month]} year={@form[:date_start_year]} />
        <.month_picker month={@form[:date_end_month]} year={@form[:date_end_year]} />
      </div>
      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur" />
      <.input field={@form[:field_of_study]} label="Field of Study" phx-debounce="blur" />
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :index, :integer, required: true

  defp skill_form(assigns) do
    ~H"""
    <.entity on_delete="skill:delete">
      <.input field={@form[:title]} label="Title" phx-debounce="blur" />
      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur" />
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :index, :integer, required: true

  defp experience_form(assigns) do
    ~H"""
    <.entity on_delete="experience:delete">
      <div class="grid grid-cols-[2fr_1fr] gap-4">
        <.input field={@form[:title]} label="Title" phx-debounce="blur" />
        <.input
          type="select"
          field={@form[:employment_type]}
          label="Employment Type"
          prompt="--"
          options={Experience.employment_types()}
        />
        <.input field={@form[:organization]} label="Company, Organization, etc." phx-debounce="blur" />
        <.input field={@form[:location]} label="Country, City, etc." phx-debounce="blur" />
      </div>
      <div class="grid grid-cols-2 gap-4">
        <.month_picker month={@form[:date_start_month]} year={@form[:date_start_year]} />
        <.month_picker month={@form[:date_end_month]} year={@form[:date_end_year]} />
      </div>
      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur" />
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  defp content_form(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.fieldset title="Basic Information">
        <.entity>
          <.input field={@form[:name]} label="Name" phx-debounce="blur" />
          <.input field={@form[:position]} label="Position" phx-debounce="blur" />
        </.entity>
      </.fieldset>
      <.fieldset title="Skills" on_add="skill:add">
        <.inputs_for :let={skill} field={@form[:skills]}>
          <.skill_form form={skill} index={skill.index} />
        </.inputs_for>
      </.fieldset>

      <.fieldset title="Experience" on_add="experience:add">
        <.inputs_for :let={experience} field={@form[:experiences]}>
          <.experience_form form={experience} index={experience.index} />
        </.inputs_for>
      </.fieldset>

      <.fieldset title="Education" on_add="education:add">
        <.inputs_for :let={education} field={@form[:educations]}>
          <.education_form form={education} index={education.index} />
        </.inputs_for>
      </.fieldset>

      <.fieldset title="Foreign Languages" on_add="language:add">
        <.inputs_for :let={language} field={@form[:languages]}>
          <.language_form form={language} index={language.index} />
        </.inputs_for>
      </.fieldset>
    </div>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  def cv_form(assigns) do
    ~H"""
    <.form for={@form} phx-change="cv:save" phx-submit="cv:save" class="flex flex-col gap-6">
      <.entity>
        <.input field={@form[:title]} label="Title" phx-debounce="blur" />
      </.entity>
      <.inputs_for :let={content} field={@form[:content]}>
        <.content_form form={content} />
      </.inputs_for>
      <div class="text-right">
        <.button type="submit" class="w-full">Save</.button>
      </div>
    </.form>
    """
  end
end
