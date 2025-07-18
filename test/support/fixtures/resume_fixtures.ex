defmodule ModernResume.ResumeFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ModernResume.Resume` context.
  """

  @doc """
  Generate a cv.
  """
  def cv_fixture(attrs \\ %{}) do
    {:ok, cv} =
      attrs
      |> add_user_if_exists()
      |> Enum.into(%{
        content: %{
          name: "John Doe",
          position: "Test Sampe",
          skills: [],
          experiences: [],
          educations: [],
          languages: [],
          settings: %{
            style: :banking,
            color: :blue,
            font_size: :font_size_11pt,
            font_family: :sans,
            use_icons: true
          }
        },
        title: "some title"
      })
      |> ModernResume.Resume.create_cv()

    cv
  end

  def add_user_if_exists(attrs) when is_map(attrs) do
    attrs
    |> Map.put_new_lazy(:user_id, fn ->
      ModernResume.AccountsFixtures.user_fixture().id
    end)
  end
end
