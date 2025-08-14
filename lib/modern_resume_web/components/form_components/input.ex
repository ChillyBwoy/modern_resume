defmodule ModernResumeWeb.FormComponents.Input do
  use Phoenix.Component
  use Gettext, backend: ModernResumeWeb.Gettext

  import ModernResumeWeb.FormComponents.Error

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :show_counter, :boolean,
    default: false,
    doc: "whether to show character counter for inputs with maxlength"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <span class="flex items-center">
      <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value="true"
        checked={@checked}
        data-checked="&#x2713;"
        class="bg-form-background relative appearance-none outline-hidden border-primary text-secondary-dark rounded-xs border focus:ring-primary-light focus:ring-2 focus:outline-hidden disabled:border-secondary-dark/20 disabled:text-secondary-light before:absolute before:top-0 before:right-0 before:bottom-0 before:left-0 before:flex before:items-center before:justify-center before:text-primary before:text-sm before:font-bold checked:before:content-[attr(data-checked)] disabled:before:text-secondary-light size-5"
        {@rest}
      />
    </span>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <span class="after:form-select-icon relative inline-block w-full after:content-[' '] after:absolute after:block after:h-2 after:w-3 after:bg-secondary after:top-4 after:right-4 after:pointer-events-none">
      <select
        id={@id}
        name={@name}
        class={[
          "bg-form-background text-secondary-dark disabled:border-secondary-dark/20 disabled:text-secondary-light h-9 w-full appearance-none rounded-md border px-2 focus:ring-2 focus:outline-hidden",
          @errors == [] && "border-secondary-light focus:ring-primary-light",
          @errors != [] && "border-danger focus:ring-danger-light"
        ]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
    </span>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    maxlength = assigns[:maxlength] || assigns[:rest][:maxlength]

    assigns =
      assign(assigns,
        maxlength: maxlength,
        has_counter: assigns[:show_counter] && maxlength != nil
      )

    ~H"""
    <div
      id={"#{@id}-container"}
      class="relative"
      data-max-length={@maxlength}
      phx-hook={@has_counter && "CharacterCounter"}
    >
      <textarea
        id={@id}
        name={@name}
        rows="5"
        data-type={@has_counter && "CharacterCounter.input"}
        class={[
          "bg-form-background text-secondary-dark placeholder:text-secondary-light disabled:border-secondary-dark/20 disabled:text-secondary-light block w-full rounded-md border px-2 focus:ring-2 focus:outline-none",
          @errors == [] && "border-secondary-light focus:ring-primary-light",
          @errors != [] && "border-danger focus:ring-danger-light"
        ]}
        {@rest}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      <.input_char_counter
        :if={@has_counter}
        value={String.length(@value || "")}
        maxlength={@maxlength}
        type="textarea"
      />
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    maxlength = assigns[:maxlength] || assigns[:rest][:maxlength]

    assigns =
      assign(assigns,
        maxlength: maxlength,
        normalized_value: Phoenix.HTML.Form.normalize_value(assigns.type, assigns.value || ""),
        has_counter: assigns[:show_counter] && maxlength != nil
      )

    ~H"""
    <div
      class="relative"
      id={"#{@id}-container"}
      data-max-length={@maxlength}
      phx-hook={@has_counter && "CharacterCounter"}
    >
      <input
        type={@type}
        name={@name}
        id={@id}
        value={@normalized_value}
        data-type={@has_counter && "CharacterCounter.input"}
        class={[
          "bg-form-background text-secondary-dark placeholder:text-secondary-light disabled:border-secondary-dark/20 disabled:text-secondary-light block h-9 w-full rounded-md border focus:ring-2 focus:outline-none",
          @errors == [] && "border-secondary-light focus:ring-primary-light",
          @errors != [] && "border-danger focus:ring-danger-light",
          @has_counter && "pl-2 pr-14",
          !@has_counter && "px-2"
        ]}
        {@rest}
      />
      <.input_char_counter
        :if={@has_counter}
        value={String.length(@normalized_value)}
        maxlength={@maxlength}
        type="input"
      />
    </div>
    """
  end

  attr :value, :integer, required: true
  attr :maxlength, :string, required: true
  attr :type, :string, values: ["input", "textarea"], required: true

  defp input_char_counter(assigns) do
    ~H"""
    <div class={[
      "text-xs text-secondary pointer-events-none flex",
      @type == "input" &&
        "absolute top-px bottom-px right-px items-center justify-center rounded-r-md w-14",
      @type == "textarea" && "justify-end py-1"
    ]}>
      <span data-type="CharacterCounter.counter">{@value}</span>
      <span>/</span>
      <span>{@maxlength}</span>
    </div>
    """
  end
end
