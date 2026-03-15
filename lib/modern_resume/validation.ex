defmodule ModernResume.Validation do
  @moduledoc """
  Validation functions
  """
  alias Ecto.Changeset

  @latex_allowed_char ~r/[\s\d\w\@\+\-_\.,'"\(\)\{\}\&\%\^\|\~\#\/\\]/ui
  @latex_allowed_string ~r/^[\s\d\w\@\+\-_\.,'"\(\)\{\}\&\%\^\|\~\#\/\\]+$/ui

  def validate_latex_chars(%Changeset{valid?: false} = changeset, fields)
      when is_list(fields) do
    changeset
  end

  def validate_latex_chars(%Changeset{} = changeset, fields) when is_list(fields) do
    Enum.reduce(fields, changeset, fn field, ch ->
      case Changeset.get_field(ch, field) |> validate_latex_field() do
        {:ok, _} ->
          ch

        {:error, invalid_chars} ->
          msg = "Invalid chars: #{Enum.join(invalid_chars, ", ")}"

          Changeset.add_error(ch, field, msg)
      end
    end)
  end

  defp validate_latex_field(value) when not is_binary(value), do: {:ok, value}
  defp validate_latex_field(""), do: {:ok, ""}

  defp validate_latex_field(value) when is_binary(value) do
    if String.match?(value, @latex_allowed_string) do
      {:ok, value}
    else
      invalid_chars =
        @latex_allowed_char
        |> Regex.replace(value, "", global: true)
        |> String.split("", trim: true)

      {:error, invalid_chars}
    end
  end
end
