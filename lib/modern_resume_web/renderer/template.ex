defmodule ModernResumeWeb.Renderer.Template do
  @enforce_keys [:name, :content]
  defstruct [:name, :content]

  # Collection of templates: https://www.overleaf.com/latex/templates/tagged/cv/page/2

  def new(name) when is_binary(name) do
    content =
      File.cwd!()
      |> Path.join("lib/modern_resume_web/renderer/#{name}.tex.eex")
      |> EEx.compile_file(trim: true)

    %__MODULE__{name: name, content: content}
  end

  def eval(%__MODULE__{content: content}, assigns) do
    with {tpl, _} <- Code.eval_quoted(content, assigns) do
      tpl
      |> String.replace(~r/\\\\/, "\\")
      |> String.replace(~r/\n\n\n/, "\n")
    end
  end
end
