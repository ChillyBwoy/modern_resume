defmodule ModernResumeWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ModernResumeWeb, :html

  import ModernUI.Components.Flash

  alias ModernResume.Accounts.User

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, User, required: true
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="h-full">
      <header class="sticky top-0 bg-white z-50 shadow-md h-16">
        <.top_menu current_user={@current_user} />
      </header>
      <main class="h-full relative -mt-16 pt-20 pl-6 pr-6">
        {render_slot(@inner_block)}
      </main>
      <.flash_group flash={@flash} />
    </div>
    """
  end

  attr :flash, :map, required: true
  slot :inner_block, required: true

  def auth(assigns) do
    ~H"""
    <main class="h-full relative flex items-center">
      <div class="mx-auto w-sm flex flex-col gap-4">
        {render_slot(@inner_block)}
      </div>
    </main>
    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end

  attr :current_user, User, required: true

  defp top_menu(assigns) do
    ~H"""
    <nav class="h-full flex items-center">
      <ul class="relative flex items-center gap-4 p-4 w-full justify-end ">
        <%= if @current_user do %>
          <li>
            <.link href={~p"/users/settings"}>Settings</.link>
          </li>
          <li>
            <.link href={~p"/users/log_out"} method="delete">Log out</.link>
          </li>
        <% else %>
          <li>
            <.link href={~p"/users/register"}>Register</.link>
          </li>
          <li>
            <.link href={~p"/users/log_in"}>Log in</.link>
          </li>
        <% end %>
      </ul>
    </nav>
    """
  end
end
