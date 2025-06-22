defmodule ModernResume.Resume.SkillTest do
  use ModernResume.DataCase

  alias ModernResume.Resume

  describe "skills" do
    alias ModernResume.Resume.CV

    import ModernResume.ResumeFixtures

    test "add_skill/2 adds a new skill" do
      cv = cv_fixture()

      assert {:ok, %CV{} = cv} =
               Resume.add_skill(cv, %{title: "test title", description: "test description"})

      skill = cv.content.skills |> List.last()

      assert skill.title == "test title"
      assert skill.description == "test description"
    end

    test "add_skill/2 adds a new skill with invalid params" do
      cv = cv_fixture()

      assert {:error, changeset} = Resume.add_skill(cv, %{title: "", description: ""})

      assert changeset.errors == [
               {:title, {"can't be blank", [validation: :required]}},
               {:description, {"can't be blank", [validation: :required]}}
             ]
    end

    test "update_skill/2 updates an existing skill in content" do
      cv = cv_fixture()

      assert {:ok, cv} =
               Resume.add_skill(cv, %{title: "test title 1", description: "test description 1"})

      assert {:ok, cv} =
               Resume.add_skill(cv, %{title: "test title 2", description: "test description 2"})

      assert {:ok, cv} =
               Resume.add_skill(cv, %{title: "test title 3", description: "test description 3"})

      assert Enum.at(cv.content.skills, 0).title == "test title 1"
      assert Enum.at(cv.content.skills, 0).description == "test description 1"

      assert Enum.at(cv.content.skills, 1).title == "test title 2"
      assert Enum.at(cv.content.skills, 1).description == "test description 2"

      assert Enum.at(cv.content.skills, 2).title == "test title 3"
      assert Enum.at(cv.content.skills, 2).description == "test description 3"

      assert {:ok, %CV{} = cv} =
               Resume.update_skill(cv, Enum.at(cv.content.skills, 1).id, %{
                 title: "updated title",
                 description: "updated description"
               })

      assert Enum.at(cv.content.skills, 0).title == "test title 1"
      assert Enum.at(cv.content.skills, 0).description == "test description 1"

      assert Enum.at(cv.content.skills, 1).title == "updated title"
      assert Enum.at(cv.content.skills, 1).description == "updated description"

      assert Enum.at(cv.content.skills, 2).title == "test title 3"
      assert Enum.at(cv.content.skills, 2).description == "test description 3"
    end
  end
end
