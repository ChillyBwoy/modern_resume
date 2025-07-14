defmodule ModernResumeWeb.Formatters do
  @datetime_format "%Y-%m-%d %H:%M"
  # @datetime_format "%B %d, %Y %H:%M"

  def format_datetime(%DateTime{} = datetime) do
    case Timex.Timezone.Local.lookup() do
      tz when is_binary(tz) ->
        datetime
        |> Timex.Timezone.convert(tz)
        |> Timex.format!(@datetime_format, :strftime)

      {:error, _} ->
        Timex.format!(datetime, @datetime_format, :strftime)
    end
  end
end
