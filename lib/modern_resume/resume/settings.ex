defmodule ModernResume.Resume.Settings do
  use Ecto.Schema
  import Ecto.Changeset

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

  def changeset(settings \\ %__MODULE__{}, attrs \\ %{}) do
    settings
    |> cast(attrs, [:color, :style, :font_size, :font_family, :use_icons])
    |> validate_required([:color, :style, :font_size, :font_family, :use_icons])
  end

  def style_choices do
    Enum.map(@styles, fn item ->
      {item, item}
    end)
  end

  def color_choices do
    Enum.map(@colors, fn item ->
      {item, item}
    end)
  end

  def font_size_choices do
    Enum.map(@font_sizes, fn item ->
      {display_font_size(item), item}
    end)
  end

  def font_family_choices do
    Enum.map(@font_families, fn item ->
      {item, item}
    end)
  end

  def display_font_size(:font_size_10pt), do: "10pt"
  def display_font_size(:font_size_11pt), do: "11pt"
  def display_font_size(:font_size_12pt), do: "12pt"
  def display_font_size(_), do: raise("Invalid font size")
end
