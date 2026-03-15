defmodule ModernResumeWeb.Formatters do
  @moduledoc """
  Formatters
  """
  alias Timex.Timezone

  @datetime_format "%Y-%m-%d %H:%M"

  def format_datetime(%DateTime{} = datetime) do
    case Timezone.Local.lookup() do
      tz when is_binary(tz) ->
        datetime
        |> Timezone.convert(tz)
        |> Timex.format!(@datetime_format, :strftime)

      {:error, _} ->
        Timex.format!(datetime, @datetime_format, :strftime)
    end
  end
end
