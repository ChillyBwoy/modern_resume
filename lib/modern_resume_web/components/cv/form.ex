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

  defp is_sortable(%Phoenix.HTML.Form{} = form, key) when is_atom(key) do
    length(form[key].value) > 1
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
  attr :sortable, :boolean, required: true
  attr :index, :integer, default: nil

  slot :inner_block, required: true
  slot :extra, required: false

  defp entity(assigns) do
    ~H"""
    <div data-index={@index}>
      <div class="group relative px-2 pr-10  transition-[scale]">
        <div class="flex flex-col gap-4 rounded-lg focus-within:shadow-lg focus-within:shadow-black/40 relative p-3 border border-gray-300 focus-within:bg-zinc-100">
          {render_slot(@inner_block)}
        </div>

        <div
          :if={@on_delete != nil or @sortable}
          class="absolute opacity-0 group-hover:opacity-100 top-0 right-0 bg-white px-2 py-1 rounded-lg border border-gray-300 flex flex-col items-center gap-4 pointer-events-auto focus:outline-none"
          tabindex="0"
        >
          <span :if={@sortable} data-type="sort-handle" class="flex items-center">
            <.icon name="hero-bars-3" class="size-4 text-gray-600 cursor-move" />
          </span>
          <button
            :if={@on_delete != nil}
            type="button"
            data-confirm="Delete this experience?"
            phx-value-index={@index}
            phx-click={@on_delete}
            tabindex="-1"
            class="flex items-center"
          >
            <.icon name="hero-trash" class="size-4 text-rose-600" />
          </button>
        </div>
      </div>
      <div :if={@extra != []} class="pl-20 pr-10">
        <div class="border-l border-b border-r rounded-b-md border-gray-300 pb-4">
          {render_slot(@extra)}
        </div>
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :parent_id, :string, required: true
  attr :title, :string, required: true
  attr :on_add, :string, default: nil
  attr :on_sort, :string, default: nil
  slot :inner_block, required: true

  defp fieldset(assigns) do
    ~H"""
    <fieldset class="flex flex-col gap-2">
      <legend class="text-xl font-bold block px-2 mb-2">
        {@title}
      </legend>
      <div
        id={"#{@id}:#{@parent_id}:list"}
        class="flex flex-col gap-4"
        data-sort-action={@on_sort}
        phx-hook="Sortable"
      >
        {render_slot(@inner_block)}
      </div>
      <div
        :if={@on_add != nil}
        class="relative flex items-center justify-center before:absolute before:h-px before:bg-gray-200 before:left-0 before:right-0"
      >
        <button
          type="button"
          phx-value-parent_id={@parent_id}
          phx-click={@on_add}
          class="size-8 bg-black rounded-full flex items-center justify-center z-10 cursor-pointer"
        >
          <.icon name="hero-plus" class="size-6 text-white" />
        </button>
      </div>
    </fieldset>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true

  defp language_form(assigns) do
    ~H"""
    <.entity sortable={@sortable} on_delete="languages:delete" index={@form.index}>
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
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true

  defp education_form(assigns) do
    ~H"""
    <.entity sortable={@sortable} on_delete="educations:delete" index={@form.index}>
      <.input field={@form[:degree]} label="Degree" phx-debounce="blur" />
      <.input field={@form[:institution]} label="Institution" phx-debounce="blur" />
      <.input field={@form[:location]} label="Country, City, etc." phx-debounce="blur" />
      <div class="grid grid-cols-2 gap-4">
        <.month_picker month={@form[:date_start_month]} year={@form[:date_start_year]} />
        <.month_picker month={@form[:date_end_month]} year={@form[:date_end_year]} />
      </div>
      <.input field={@form[:field_of_study]} label="Field of Study" phx-debounce="blur" />
      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur" />
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true

  defp skill_form(assigns) do
    ~H"""
    <.entity sortable={@sortable} on_delete="skills:delete" index={@form.index}>
      <.input field={@form[:title]} label="Title" phx-debounce="blur" />
      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur" />
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true

  defp experience_detail_form(assigns) do
    ~H"""
    <.entity sortable={@sortable} on_delete="experience_details:delete" index={@form.index}>
      <.input field={@form[:content]} label="Content" phx-debounce="blur" />
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true

  defp experience_form(assigns) do
    ~H"""
    <.entity sortable={@sortable} on_delete="experiences:delete" index={@form.index}>
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

      <:extra>
        <.fieldset
          :if={assigns.form.data.id != nil}
          id="experience_details"
          title="Details"
          on_add="experience_details:add"
          on_sort="experience_details:sort"
          parent_id={assigns.form.data.id}
        >
          <.inputs_for :let={details} field={@form[:details]}>
            <.experience_detail_form
              form={details}
              index={details.index}
              sortable={is_sortable(@form, :details)}
            />
          </.inputs_for>
        </.fieldset>
      </:extra>
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  defp basic_info_form(assigns) do
    ~H"""
    <.entity sortable={false}>
      <.input field={@form[:position]} label="Title" phx-debounce="blur" />
      <.input field={@form[:name]} label="Name" phx-debounce="blur" />
      <div class="grid grid-cols-2 gap-4">
        <.input field={@form[:email]} type="email" label="Email" phx-debounce="blur" />
        <.input field={@form[:phone]} type="tel" label="Phone" phx-debounce="blur" />
      </div>
      <.input field={@form[:location]} label="Country, City, etc." phx-debounce="blur" />
      <.input field={@form[:birthdate]} type="date" label="Birthdate" phx-debounce="blur" />
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  defp content_form(assigns) do
    ~H"""
    <div class="flex flex-col gap-4">
      <.fieldset id="basic_info" parent_id="content" title="Basic Information">
        <.basic_info_form form={@form} />
      </.fieldset>

      <.fieldset
        id="skills"
        parent_id="content"
        title="Skills"
        on_add="skills:add"
        on_sort="skills:sort"
      >
        <.inputs_for :let={skill} field={@form[:skills]}>
          <.skill_form form={skill} index={skill.index} sortable={is_sortable(@form, :skills)} />
        </.inputs_for>
      </.fieldset>

      <.fieldset
        id="experiences"
        parent_id="content"
        title="Experience"
        on_add="experiences:add"
        on_sort="experiences:sort"
      >
        <.inputs_for :let={experience} field={@form[:experiences]}>
          <.experience_form
            form={experience}
            index={experience.index}
            sortable={is_sortable(@form, :experiences)}
          />
        </.inputs_for>
      </.fieldset>

      <.fieldset
        id="educations"
        parent_id="content"
        title="Education"
        on_add="educations:add"
        on_sort="educations:sort"
      >
        <.inputs_for :let={education} field={@form[:educations]}>
          <.education_form
            form={education}
            index={education.index}
            sortable={is_sortable(@form, :educations)}
          />
        </.inputs_for>
      </.fieldset>

      <.fieldset
        id="languages"
        parent_id="content"
        title="Foreign Languages"
        on_add="languages:add"
        on_sort="languages:sort"
      >
        <.inputs_for :let={language} field={@form[:languages]}>
          <.language_form
            form={language}
            index={language.index}
            sortable={is_sortable(@form, :languages)}
          />
        </.inputs_for>
      </.fieldset>
    </div>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  def cv_form(assigns) do
    ~H"""
    <.form for={@form} phx-change="cv:save" phx-submit="cv:save" class="flex flex-col gap-6">
      <.entity sortable={false}>
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
