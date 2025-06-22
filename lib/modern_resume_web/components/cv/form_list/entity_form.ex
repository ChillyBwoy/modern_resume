defmodule ModernResumeWeb.CV.FormList.EntityForm do
  @type assigns :: map()

  @callback render_form(assigns) :: Phoenix.LiveView.Rendered.t()
end
