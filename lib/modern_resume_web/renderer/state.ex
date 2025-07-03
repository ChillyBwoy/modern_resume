defmodule ModernResumeWeb.Renderer.State do
  @enforce_keys [:status, :content, :error]
  defstruct [:status, :content, :error]

  def idle do
    %__MODULE__{status: :idle, content: nil, error: nil}
  end

  def loading do
    %__MODULE__{status: :loading, content: nil, error: nil}
  end

  def error(msg) do
    %__MODULE__{status: :error, content: nil, error: msg}
  end

  def source(content) when is_binary(content) do
    %__MODULE__{status: :source, content: content, error: nil}
  end

  def pdf(content) when is_binary(content) do
    %__MODULE__{status: :pdf, content: content, error: nil}
  end
end
