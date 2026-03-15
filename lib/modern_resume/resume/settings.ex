defmodule ModernResume.Resume.Settings do
  @moduledoc """
  CV settings schema
  """
  use Ecto.Schema

  alias Ecto.Changeset

  @type style :: :casual | :classic | :banking | :oldstyle | :fancy
  @type color :: :black | :blue | :burgundy | :green | :grey | :orange | :purple | :red
  @type font_size :: :font_size_10pt | :font_size_11pt | :font_size_12pt
  @type font_family :: :sans | :roman
  @type t :: %__MODULE__{
          style: style(),
          color: color(),
          font_size: font_size(),
          font_family: font_family(),
          use_icons: boolean()
        }

  @styles [
    :casual,
    :classic,
    :banking,
    :oldstyle,
    :fancy
  ]

  @colors [
    :black,
    :blue,
    :burgundy,
    :green,
    :grey,
    :orange,
    :purple,
    :red
  ]

  @font_sizes [:font_size_10pt, :font_size_11pt, :font_size_12pt]

  @font_families [:sans, :roman]

  embedded_schema do
    field :style, Ecto.Enum, values: @styles, default: :banking
    field :color, Ecto.Enum, values: @colors, default: :blue
    field :font_size, Ecto.Enum, values: @font_sizes, default: :font_size_11pt
    field :font_family, Ecto.Enum, values: @font_families, default: :sans
    field :use_icons, :boolean, default: true
  end

  @spec changeset(t() | %__MODULE__{}, map()) :: Changeset.t(t())
  def changeset(%__MODULE__{} = settings, attrs \\ %{}) do
    settings
    |> Changeset.cast(attrs, [:color, :style, :font_size, :font_family, :use_icons])
    |> Changeset.validate_required([:color, :style, :font_size, :font_family, :use_icons])
  end

  @spec style_choices() :: list({String.t(), style()})
  def style_choices, do: Enum.map(@styles, &{"#{&1}", &1})

  @spec color_choices() :: list({String.t(), color()})
  def color_choices, do: Enum.map(@colors, &{"#{&1}", &1})

  @spec font_size_choices() :: list({String.t(), font_size()})
  def font_size_choices, do: Enum.map(@font_sizes, &{display_font_size(&1), &1})

  @spec font_family_choices() :: list({String.t(), font_family()})
  def font_family_choices, do: Enum.map(@font_families, &{"#{&1}", &1})

  @spec display_font_size(font_size()) :: String.t()
  def display_font_size(:font_size_10pt), do: "10pt"
  def display_font_size(:font_size_11pt), do: "11pt"
  def display_font_size(:font_size_12pt), do: "12pt"
  def display_font_size(_), do: raise("Invalid font size")
end
