defmodule ModernResume.ResumeTest do
  use ModernResume.DataCase

  alias ModernResume.Resume

  describe "cvs" do
    alias ModernResume.Resume.CV
    alias ModernResume.Resume.Content

    import ModernResume.ResumeFixtures

    @invalid_attrs %{title: nil, content: nil}

    test "list_cvs/0 returns all cvs" do
      cv = cv_fixture()
      assert Resume.list_cvs() == [cv]
    end

    test "get_cv!/1 returns the cv with given id" do
      cv = cv_fixture()
      assert Resume.get_cv!(cv.id) == cv
    end

    test "create_cv/1 with valid data creates a cv" do
      valid_attrs = %{
        title: "some title",
        content: %{
          name: "John Doe",
          position: "Test Sample"
        }
      }

      assert {:ok, %CV{} = cv} = Resume.create_cv(valid_attrs)

      assert cv.title == "some title"

      assert cv.content == %Content{
               name: "John Doe",
               position: "Test Sample",
               birthdate: nil,
               email: nil,
               location: nil,
               phone: nil,
               skills: [],
               experiences: [],
               educations: [],
               languages: []
             }
    end

    test "create_cv/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resume.create_cv(@invalid_attrs)
    end

    test "update_cv/2 with valid data updates the cv" do
      cv = cv_fixture()

      update_attrs = %{
        title: "some updated title",
        content: %{
          name: "Jane Doe",
          position: "Manager"
        }
      }

      assert {:ok, %CV{} = cv} = Resume.update_cv(cv, update_attrs)
      assert cv.title == "some updated title"

      assert cv.content == %Content{
               name: "Jane Doe",
               position: "Manager",
               birthdate: nil,
               email: nil,
               location: nil,
               phone: nil,
               skills: [],
               experiences: [],
               educations: [],
               languages: []
             }
    end

    test "update_cv/2 with invalid data returns error changeset" do
      cv = cv_fixture()
      assert {:error, %Ecto.Changeset{}} = Resume.update_cv(cv, @invalid_attrs)
      assert cv == Resume.get_cv!(cv.id)
    end

    test "delete_cv/1 deletes the cv" do
      cv = cv_fixture()
      assert {:ok, %CV{}} = Resume.delete_cv(cv)
      assert_raise Ecto.NoResultsError, fn -> Resume.get_cv!(cv.id) end
    end

    test "add_skill/2 adds a new skill to content" do
      cv = cv_fixture()

      assert {:ok, %CV{} = cv} =
               Resume.add_skill(cv, %{title: "test title", description: "test description"})

      skill = cv.content.skills |> List.last()

      assert skill.title == "test title"
      assert skill.description == "test description"
    end

    test "update_skill/2 updates an existing skill in content" do
      cv = cv_fixture()
      # assert {:ok, %CV{} = cv} =
      #        Resume.add_skill(cv, %{title: "test title", description: "test description"})
      #   # skill = %{title: "test title", description: "test description"}
      #   # {:ok, cv} = Resume.add_skill(cv, skill)

      #   # updated_skill = %{title: "updated title", description: "updated description"}
      #   # assert {:ok, %CV{} = cv} = Resume.update_skill(cv, skill, updated_skill)

      #   # skill_in_cv = Enum.find(cv.content.skills, fn s -> s.title == "updated title" end)
      #   # assert skill_in_cv.description == "updated description"
    end
  end
end
