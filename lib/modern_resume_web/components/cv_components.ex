defmodule ModernResumeWeb.CVComponents do
  use Phoenix.Component

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def cv_item(assigns) do
    ~H"""
    <div class={[
      "rounded-lg focus-within:shadow-xl focus-within:ring-1 focus-within:ring-gray-100 relative py-2 px-3",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :title, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def cv_section(assigns) do
    ~H"""
    <div class={["flex flex-col gap-1", @class]} {@rest}>
      <h1 class="text-xl text-gray-400">{@title}</h1>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :title, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def cv_subsection(assigns) do
    ~H"""
    <div class={["flex flex-col gap-1", @class]} {@rest}>
      <h3 class="text-lg text-gray-400">{@title}</h3>
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :date_start, required: true
  slot :date_end, required: true

  def date_range(assigns) do
    ~H"""
    <div class="inline-flex w-min items-start gap-x-2 text-sm">
      <div class="flex flex-col gap-1 items-end">{render_slot(@date_start)}</div>
      <span>~</span>
      <div class="flex flex-col gap-1">{render_slot(@date_end)}</div>
    </div>
    """
  end

  attr :errors, :list, required: true
  attr :rest, :global

  def error_list(assigns) do
    ~H"""
    <span class="flex flex-col text-xs text-rose-600 z-10 top-full" {@rest}>
      <p :for={msg <- @errors}>{msg}</p>
    </span>
    """
  end
end
