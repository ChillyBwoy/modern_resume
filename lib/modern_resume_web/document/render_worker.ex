defmodule ModernResumeWeb.Document.RenderWorker do
  @moduledoc """
  Document render worker
  """
  use Task

  alias Phoenix.PubSub

  alias ModernResume.Resume.CV
  alias ModernResumeWeb.Document.Renderer

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run({%CV{} = cv, type}) do
    case Renderer.render(cv, type) do
      {:ok, content} ->
        PubSub.broadcast(ModernResume.PubSub, get_topic(cv), {:renderer, {:ok, type, content}})

      {:error, msg} ->
        PubSub.broadcast(ModernResume.PubSub, get_topic(cv), {:renderer, {:error, msg}})
    end
  end

  @spec subscribe(CV.t()) :: :ok | {:error, term()}
  def subscribe(%CV{} = cv) do
    PubSub.subscribe(ModernResume.PubSub, get_topic(cv))
  end

  @spec unsubscribe(CV.t()) :: :ok
  def unsubscribe(%CV{} = cv) do
    PubSub.unsubscribe(ModernResume.PubSub, get_topic(cv))
  end

  defp get_topic(%CV{} = cv), do: "#{inspect(__MODULE__)}:#{cv.id}"
end
