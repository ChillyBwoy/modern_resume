defmodule ModernResumeWeb.Renderer.RenderState do
  @enforce_keys [:status, :content_pdf, :content_str, :content_type, :error]
  defstruct [
    :status,
    :content_pdf,
    :content_str,
    :content_type,
    :error
  ]

  alias ModernResumeWeb.Renderer.RenderState

  def init() do
    %RenderState{status: :idle, content_pdf: nil, content_str: nil, content_type: nil, error: nil}
  end

  def loading(%RenderState{} = state) do
    %RenderState{state | status: :loading, error: nil}
  end

  def error(%RenderState{} = state, msg) when is_binary(msg) do
    %RenderState{state | status: :error, error: msg}
  end

  def success(%RenderState{} = state, type, content) when is_atom(type) and is_binary(content) do
    case type do
      :pdf ->
        %RenderState{
          state
          | status: :success,
            content_pdf: content,
            error: nil
        }

      :str ->
        %RenderState{
          state
          | status: :success,
            content_str: content,
            error: nil
        }
    end
  end

  def success(_, _, _) do
    raise "Invalid type"
  end

  def content_type(%RenderState{} = state, :str), do: %RenderState{state | content_type: :str}
  def content_type(%RenderState{} = state, :pdf), do: %RenderState{state | content_type: :pdf}
  def content_type(_, _), do: raise("Invalid content type")

  def toggle_content_type(%RenderState{content_type: :pdf} = state) do
    %RenderState{state | content_type: :str}
  end

  def toggle_content_type(%RenderState{content_type: :str} = state) do
    %RenderState{state | content_type: :pdf}
  end

  def toggle_content_type(_), do: raise("Toggle invalid content type")
end
