defmodule ModernResumeWeb.Document.RenderWorker do
  use Task

  alias ModernResume.PubSub
  alias ModernResume.Resume.CV
  alias ModernResumeWeb.Document.Renderer

  @topic inspect(__MODULE__)

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run({%CV{} = cv, type}) do
    case Renderer.render(cv, type) do
      {:ok, content} ->
        Phoenix.PubSub.broadcast(PubSub, @topic, {:renderer, {:ok, type, content}})

      {:error, msg} ->
        Phoenix.PubSub.broadcast(PubSub, @topic, {:renderer, {:error, msg}})
    end
  end

  def subscribe do
    Phoenix.PubSub.subscribe(PubSub, @topic)
  end

  def unsubscribe do
    Phoenix.PubSub.unsubscribe(PubSub, @topic)
  end
end
