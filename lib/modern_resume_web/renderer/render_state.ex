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

  def error(%__MODULE__{} = state, msg) when is_binary(msg) do
    %__MODULE__{state | status: :error, error: msg}
  end

  def success(%__MODULE__{} = state, type, content) when is_atom(type) and is_binary(content) do
    case type do
      :pdf ->
        %__MODULE__{
          state
          | status: :success,
            content_pdf: content,
            error: nil
        }

      :str ->
        %__MODULE__{
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

  def content_type(%__MODULE__{} = state, :str), do: %__MODULE__{state | content_type: :str}
  def content_type(%__MODULE__{} = state, :pdf), do: %__MODULE__{state | content_type: :pdf}
  def content_type(_, _), do: raise("Invalid content type")

  def toggle_content_type(%__MODULE__{content_type: :pdf} = state) do
    %__MODULE__{state | content_type: :str}
  end

  def toggle_content_type(%__MODULE__{content_type: :str} = state) do
    %__MODULE__{state | content_type: :pdf}
  end

  def toggle_content_type(_), do: raise("Toggle invalid content type")
end
