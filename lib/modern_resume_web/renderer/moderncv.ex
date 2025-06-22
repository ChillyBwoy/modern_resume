defmodule ModernResumeWeb.Renderer.Moderncv do
  alias ModernResume.Resume.CV
  alias ModernResume.Resume.Language
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

  def render(%CV{} = cv, :string) do
    content = render!(cv)
    {:ok, content}
  end

  def render(%CV{} = cv, :pdf) do
    case render!(cv)
         |> Iona.source()
         |> Iona.to(:pdf) do
      {:ok, pdf} ->
        {:ok, Base.encode64(pdf)}

      _ ->
        {:error, "Error creating PDF"}
    end
  end

  def render(_, _), do: {:error, "Unsupported format or CV"}

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

  def render_date_range(_, _), do: "{}"

  def str(input) when is_binary(input) do
    Enum.reduce(@escapes, input, fn {pattern, replacement}, value ->
      String.replace(value, pattern, replacement)
    end)
  end

  def str(value), do: value

  def lang_fluency(level) when is_atom(level) do
    Language.display_fluency(level)
  end
end
