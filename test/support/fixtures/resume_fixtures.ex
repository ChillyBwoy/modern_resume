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
      |> Enum.into(%{
        content: %{
          name: "John Doe",
          position: "Test Sampe",
          skills: [],
          experiences: [],
          educations: [],
          languages: []
        },
        title: "some title"
      })
      |> ModernResume.Resume.create_cv()

    cv
  end
end
