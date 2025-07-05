defmodule ModernResumeWeb.Renderer.RenderState do
  @enforce_keys [:status, :content_pdf, :content_str, :content_type, :error]
  defstruct [
    :status,
    :content_pdf,
    :content_str,
    :content_type,
    :error
  ]

  def init() do
    %__MODULE__{status: :idle, content_pdf: nil, content_str: nil, content_type: nil, error: nil}
  end

  def loading(%__MODULE__{} = state) do
    %__MODULE__{state | status: :loading, error: nil}
  end

  def error(%__MODULE__{} = state, msg) do
    %__MODULE__{state | status: :error, error: msg}
  end

  def success(%__MODULE__{} = state, type, content) when is_atom(type) and is_binary(content) do
    case type do
      :pdf ->
        %__MODULE__{
          state
          | status: :success,
            content_pdf: content,
            content_type: :pdf,
            error: nil
        }

      :str ->
        %__MODULE__{
          state
          | status: :success,
            content_str: content,
            content_type: :str,
            error: nil
        }
    end
  end

  def success(_, _, _) do
    raise "Invalid type"
  end
end
