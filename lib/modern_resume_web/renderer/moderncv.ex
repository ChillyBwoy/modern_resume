defmodule ModernResumeWeb.Renderer.Moderncv do
  alias ModernResume.Resume.CV
  alias ModernResume.Resume.Experience
  alias ModernResume.Resume.Language
  alias ModernResume.Resume.Settings

  alias ModernResumeWeb.Renderer.Template

  @date_format "%b %Y"

  @escapes [
    {"{", "\\{"},
    {"}", "\\}"},
    {"\\", "\\textbackslash{}"},
    {"#", "\\#"},
    {"$", "\\$"},
    {"%", "\\%"},
    {"&", "\\&"},
    {"^", "\\textasciicircum{}"},
    {"_", "\\_"},
    {"|", "\\textbar{}"},
    {"~", "\\textasciitilde{}"}
  ]

  # Kanji Latex info
  # https://tex.stackexchange.com/questions/15516/how-to-write-japanese-with-latex

  def render!(%CV{} = cv) do
    Template.new("moderncv") |> Template.eval(assigns: [cv: cv.content])
  end

  def render(%CV{} = cv, :str) do
    content = render!(cv)
    {:ok, content}
  end

  def render(%CV{} = cv, :pdf) do
    try do
      case render!(cv)
           |> Iona.source()
           |> Iona.to(:pdf, preprocess: [&preprocessor/2]) do
        {:ok, pdf} ->
          {:ok, Base.encode64(pdf)}

        _ ->
          {:error, "Error creating PDF"}
      end
    rescue
      _ ->
        {:error, "Error creating PDF"}
    end
  end

  def render(_, _), do: {:error, "Unsupported format or CV"}

  def render_date_range({start_year, start_month}, {end_year, end_month}) do
    date_start = year_month_to_date(start_year, start_month)
    date_end = year_month_to_date(end_year, end_month)

    render_date_range(date_start, date_end)
  end

  def render_date_range(%Date{} = date_start, %Date{} = date_end) do
    with {:ok, str_start} <- Timex.format(date_start, @date_format, :strftime),
         {:ok, str_end} <- Timex.format(date_end, @date_format, :strftime) do
      "#{str_start} -- #{str_end}"
    end
  end

  def render_date_range(%Date{} = date_start, _) do
    with {:ok, str_start} <- Timex.format(date_start, @date_format, :strftime) do
      "#{str_start} -- Present"
    end
  end

  defp year_month_to_date(year, month) when is_integer(year) and is_integer(month) do
    case Date.new(year, month, 1) do
      {:ok, %Date{} = date} ->
        date

      {:error, _} ->
        nil
    end
  end

  defp year_month_to_date(_, _), do: nil

  def str(input) when is_binary(input) do
    Enum.reduce(@escapes, input, fn {pattern, replacement}, value ->
      String.replace(value, pattern, replacement)
    end)
  end

  def str(value), do: value

  def lang_fluency(level) when is_atom(level), do: Language.display_fluency(level)

  def employment_type(type), do: Experience.display_employment_type(type)

  def font_size(size), do: Settings.display_font_size(size)

  defp preprocessor(_directory, source) do
    preprocessor =
      Application.fetch_env!(:modern_resume, __MODULE__)[
        :preprocessor
      ]

    case preprocessor do
      :tectonic ->
        {:shell, "tectonic #{source}"}

      :lualatex ->
        {:shell, "lualatex #{source}"}

      _ ->
        {:error, "Unknown preprocessor: #{preprocessor}"}
    end
  end
end
