defmodule ModernResumeWeb.CV.ContentForm do
  use Phoenix.Component

  import ModernResumeWeb.CoreComponents
  import ModernResumeWeb.FormComponents.Input
  import ModernResumeWeb.FormComponents.FormField

  alias Phoenix.LiveView.JS

  alias ModernResume.Resume.Language
  alias ModernResume.Resume.Experience
  alias ModernResume.Resume.Settings
  alias ModernResume.Resume.SocialNetwork

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

  def is_sortable(%Phoenix.HTML.Form{} = form, key) when is_atom(key) do
    length(form[key].value) > 1
  end

  attr :month, Phoenix.HTML.FormField, required: true
  attr :year, Phoenix.HTML.FormField, required: true

  defp month_picker(assigns) do
    ~H"""
    <div class="grid grid-cols-[2fr_1fr] gap-2">
      <.form_field field={@month}>
        <:label>Month</:label>
        <.input
          type="select"
          field={@month}
          prompt="--"
          options={get_date_options(:month)}
        />
      </.form_field>
      <.form_field field={@year}>
        <:label>Year</:label>
        <.input
          type="select"
          field={@year}
          prompt="--"
          options={get_date_options(:year)}
        />
      </.form_field>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :on_delete, :string, default: nil
  attr :sortable, :boolean, default: false
  attr :index, :integer, default: nil

  slot :inner_block, required: true

  slot :extra, required: false do
    attr :title, :string, required: true
  end

  defp entity(assigns) do
    assigns =
      assigns
      |> assign_new(:is_delitable, fn -> assigns.on_delete != nil and assigns.id != nil end)
      |> assign_new(:is_sortable, fn -> assigns.sortable and assigns.id != nil end)

    ~H"""
    <div data-index={@index} data-id={@id} data-sortable>
      <div class="relative px-2 transition-[scale] pr-10 group">
        <div class="flex flex-col gap-2 rounded-lg focus-within:shadow-lg focus-within:shadow-black/40 relative p-3 border border-gray-200 bg-white">
          {render_slot(@inner_block)}
        </div>

        <div
          :if={@is_delitable or @is_sortable}
          class="absolute opacity-0 top-0 right-0 bg-white px-2 py-1 rounded-lg border border-gray-200 flex flex-col items-center gap-4 pointer-events-auto focus:outline-none group-hover:opacity-100"
          tabindex="0"
        >
          <span :if={@is_sortable} data-type="sort-handle" class="flex items-center">
            <.icon name="mdi-drag-vertical" class="text-gray-600 cursor-move" />
          </span>
          <button
            :if={@is_delitable}
            type="button"
            data-confirm="Delete this experience?"
            tabindex="-1"
            class="flex items-center cursor-pointer"
            phx-click={JS.push(@on_delete, value: %{id: @id})}
          >
            <.icon name="mdi-trash-can-outline" class="text-rose-600" />
          </button>
        </div>
      </div>
      <div :if={@extra != []} class="pl-10 pt-2">
        <details :for={extra <- @extra} open>
          <summary class="cursor-pointer py-2">{extra.title}</summary>
          <div class="pb-4">
            {render_slot(extra)}
          </div>
        </details>
      </div>
    </div>
    """
  end

  attr :variant, :atom, values: [:full, :tiny], default: :full
  attr :on_add, JS, required: true

  defp fieldset_add(%{variant: :full} = assigns) do
    ~H"""
    <div class="px-2 relative flex items-center justify-center before:absolute before:h-px before:bg-gray-200 before:left-2 before:right-2">
      <button
        type="button"
        phx-click={@on_add}
        class="size-8 bg-black rounded-full flex items-center justify-center z-10 cursor-pointer"
      >
        <.icon name="mdi-plus" class="text-white" size="lg" />
      </button>
    </div>
    """
  end

  defp fieldset_add(%{variant: :tiny} = assigns) do
    ~H"""
    <div class="px-2 relative flex items-center justify-start before:absolute before:h-px before:bg-gray-200 before:left-2 before:right-2">
      <button
        type="button"
        phx-click={@on_add}
        class="size-5 bg-black rounded-md flex items-center justify-center z-10 cursor-pointer"
      >
        <.icon name="mdi-plus" class="text-white" />
      </button>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :parent_id, :string, default: nil
  attr :title, :string, default: nil
  attr :on_add, :string, default: nil
  attr :on_sort, :string, default: nil
  attr :variant, :atom, values: [:full, :tiny], default: :full

  slot :inner_block, required: true

  def fieldset(assigns) do
    ~H"""
    <fieldset class="flex flex-col gap-2">
      <legend :if={@title != nil} class="text-xl font-bold block px-2 mb-2">
        {@title}
      </legend>
      <div
        id={@id}
        class="flex flex-col gap-2"
        data-sort-action={
          if @on_sort != nil, do: JS.push(@on_sort, value: %{parent_id: @parent_id}), else: nil
        }
        phx-hook="Sortable"
      >
        {render_slot(@inner_block)}
      </div>

      <.fieldset_add
        :if={@on_add != nil}
        variant={@variant}
        on_add={JS.push(@on_add, value: %{parent_id: @parent_id})}
      />
    </fieldset>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true
  attr :on_delete, :string, required: true

  def language_form(assigns) do
    ~H"""
    <.entity id={@form.data.id} sortable={@sortable} on_delete={@on_delete} index={@form.index}>
      <div class="grid grid-cols-2 gap-4">
        <.form_field field={@form[:name]}>
          <:label>Name</:label>
          <.input field={@form[:name]} phx-debounce="blur" maxlength="50" show_counter />
        </.form_field>
        <.form_field field={@form[:fluency]}>
          <:label>Fluency</:label>
          <.input
            type="select"
            field={@form[:fluency]}
            prompt="--"
            options={Language.fluency_types()}
          />
        </.form_field>
      </div>
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true
  attr :on_delete, :string, required: true

  def education_form(assigns) do
    ~H"""
    <.entity id={@form.data.id} sortable={@sortable} on_delete={@on_delete} index={@form.index}>
      <.form_field field={@form[:degree]}>
        <:label>Degree</:label>
        <.input field={@form[:degree]} phx-debounce="blur" maxlength="100" show_counter />
      </.form_field>

      <div class="grid grid-cols-[2fr_1fr] gap-4">
        <.form_field field={@form[:institution]}>
          <:label>Institution</:label>
          <.input
            field={@form[:institution]}
            phx-debounce="blur"
            maxlength="100"
            show_counter
          />
        </.form_field>
        <.form_field field={@form[:location]}>
          <:label>Country, City, etc.</:label>
          <.input
            field={@form[:location]}
            phx-debounce="blur"
            maxlength="100"
            show_counter
          />
        </.form_field>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <.month_picker month={@form[:date_start_month]} year={@form[:date_start_year]} />
        <.month_picker month={@form[:date_end_month]} year={@form[:date_end_year]} />
      </div>
      <.form_field field={@form[:field_of_study]}>
        <:label>Field of Study</:label>
        <.input
          field={@form[:field_of_study]}
          phx-debounce="blur"
          maxlength="100"
          show_counter
        />
      </.form_field>
      <.form_field field={@form[:description]}>
        <:label>Description</:label>
        <.input
          field={@form[:description]}
          type="textarea"
          phx-debounce="blur"
          maxlength="500"
          show_counter
        />
      </.form_field>
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true
  attr :on_delete, :string, required: true

  def skill_form(assigns) do
    ~H"""
    <.entity id={@form.data.id} sortable={@sortable} on_delete={@on_delete} index={@form.index}>
      <.form_field field={@form[:header]}>
        <:label>Header</:label>
        <.input
          field={@form[:header]}
          phx-debounce="blur"
          maxlength="100"
          show_counter
        />
      </.form_field>

      <.form_field field={@form[:title]}>
        <:label>Title</:label>
        <.input field={@form[:title]} phx-debounce="blur" maxlength="100" show_counter />
      </.form_field>

      <.form_field field={@form[:description]}>
        <:label>Description</:label>
        <.input
          field={@form[:description]}
          type="textarea"
          phx-debounce="blur"
          maxlength="500"
          show_counter
        />
      </.form_field>
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true
  attr :on_delete, :string, required: true

  def experience_detail_form(assigns) do
    ~H"""
    <.entity id={@form.data.id} sortable={@sortable} on_delete={@on_delete} index={@form.index}>
      <.form_field field={@form[:title]}>
        <:label>Title</:label>
        <.input field={@form[:title]} phx-debounce="blur" maxlength="100" show_counter />
      </.form_field>

      <.form_field field={@form[:content]}>
        <:label>Content</:label>
        <.input
          field={@form[:content]}
          type="textarea"
          phx-debounce="blur"
          maxlength="500"
          show_counter
        />
      </.form_field>
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true
  attr :on_delete, :string, required: true
  attr :on_detail_delete, :string, required: true

  def experience_form(assigns) do
    ~H"""
    <.entity id={@form.data.id} sortable={@sortable} on_delete={@on_delete} index={@form.index}>
      <div class="grid grid-cols-[2fr_1fr] gap-4">
        <.form_field field={@form[:title]}>
          <:label>Title</:label>
          <.input field={@form[:title]} phx-debounce="blur" maxlength="100" show_counter />
        </.form_field>

        <.form_field field={@form[:employment_type]}>
          <:label>Employment Type</:label>
          <.input
            type="select"
            field={@form[:employment_type]}
            prompt="--"
            options={Experience.employment_types()}
          />
        </.form_field>

        <.form_field field={@form[:organization]}>
          <:label>Company, Organization, etc.</:label>
          <.input
            field={@form[:organization]}
            phx-debounce="blur"
            maxlength="100"
            show_counter
          />
        </.form_field>
        <.form_field field={@form[:location]}>
          <:label>Country, City, etc.</:label>
          <.input
            field={@form[:location]}
            phx-debounce="blur"
            maxlength="100"
            show_counter
          />
        </.form_field>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <.month_picker month={@form[:date_start_month]} year={@form[:date_start_year]} />
        <.month_picker month={@form[:date_end_month]} year={@form[:date_end_year]} />
      </div>
      <.form_field field={@form[:description]}>
        <:label>Description</:label>
        <.input
          field={@form[:description]}
          type="textarea"
          phx-debounce="blur"
          maxlength="500"
          show_counter
        />
      </.form_field>

      <:extra title="Work Details">
        <.fieldset
          id={"experiences:#{@form.data.id}:experience_details"}
          variant={:tiny}
          on_add="experience_details:add"
          on_sort="experience_details:sort"
          parent_id={@form.data.id}
        >
          <.inputs_for :let={details} field={@form[:details]}>
            <.experience_detail_form
              form={details}
              index={details.index}
              sortable={is_sortable(@form, :details)}
              on_delete={@on_detail_delete}
            />
          </.inputs_for>
        </.fieldset>
      </:extra>
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  def personal_info_form(assigns) do
    ~H"""
    <.entity>
      <.form_field field={@form[:position]}>
        <:label>Title</:label>
        <.input
          field={@form[:position]}
          phx-debounce="blur"
          maxlength="100"
          show_counter
        />
      </.form_field>

      <.form_field field={@form[:name]}>
        <:label>Name</:label>
        <.input field={@form[:name]} phx-debounce="blur" maxlength="50" show_counter />
      </.form_field>

      <div class="grid grid-cols-2 gap-4">
        <.form_field field={@form[:email]}>
          <:label>Email</:label>
          <.input
            field={@form[:email]}
            type="email"
            phx-debounce="blur"
            maxlength="320"
            show_counter
          />
        </.form_field>

        <.form_field field={@form[:phone]}>
          <:label>Phone</:label>
          <.input
            field={@form[:phone]}
            type="tel"
            phx-debounce="blur"
            maxlength="15"
            show_counter
          />
        </.form_field>
      </div>
      <.form_field field={@form[:location]}>
        <:label>Country, City, etc.</:label>
        <.input
          field={@form[:location]}
          phx-debounce="blur"
          maxlength="50"
          show_counter
        />
      </.form_field>

      <.form_field field={@form[:birthdate]}>
        <:label>Birthdate</:label>
        <.input field={@form[:birthdate]} type="date" phx-debounce="blur" />
      </.form_field>
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true

  def settings_form(assigns) do
    ~H"""
    <.entity>
      <.form_field field={@form[:style]}>
        <:label>Style</:label>
        <.input type="select" field={@form[:style]} options={Settings.style_choices()} />
      </.form_field>

      <.form_field field={@form[:color]}>
        <:label>Color</:label>
        <.input type="select" field={@form[:color]} options={Settings.color_choices()} />
      </.form_field>

      <.form_field field={@form[:font_size]}>
        <:label>Font Size</:label>
        <.input
          type="select"
          field={@form[:font_size]}
          options={Settings.font_size_choices()}
        />
      </.form_field>

      <.form_field field={@form[:font_family]}>
        <:label>Font Family</:label>
        <.input
          type="select"
          field={@form[:font_family]}
          options={Settings.font_family_choices()}
        />
      </.form_field>

      <.form_field field={@form[:use_icons]} position={:left}>
        <:label>Use Icons</:label>
        <.input type="checkbox" field={@form[:use_icons]} />
      </.form_field>
    </.entity>
    """
  end

  attr :form, Phoenix.HTML.Form, required: true
  attr :sortable, :boolean, required: true
  attr :index, :integer, required: true
  attr :on_delete, :string, required: true

  def social_network_form(assigns) do
    ~H"""
    <.entity id={@form.data.id} sortable={@sortable} on_delete={@on_delete} index={@form.index}>
      <div class="grid grid-cols-3 gap-1">
        <.form_field field={@form[:platform]}>
          <:label>Platform</:label>
          <.input
            type="select"
            field={@form[:platform]}
            options={SocialNetwork.platform_choices()}
          />
        </.form_field>

        <.form_field field={@form[:content]}>
          <:label>Username or Handle</:label>
          <.input
            field={@form[:content]}
            phx-debounce="blur"
            maxlength="100"
            show_counter
          />
        </.form_field>

        <.form_field field={@form[:alias]}>
          <:label>Alias</:label>
          <.input
            field={@form[:alias]}
            phx-debounce="blur"
            maxlength="100"
            show_counter
          />
        </.form_field>
      </div>
    </.entity>
    """
  end

  slot :inner_block, required: true

  def scroll_container(assigns) do
    ~H"""
    <div class="overflow-scroll absolute left-0 right-0 top-0 bottom-0 pl-1 pr-5 pb-48 pt-4 flex flex-col gap-2 scroll-container-v">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
