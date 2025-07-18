defmodule ModernResume.ResumeTest do
  use ModernResume.DataCase

  alias ModernResume.Resume

  describe "cvs" do
    import ModernResume.ResumeFixtures
    import ModernResume.AccountsFixtures

    alias ModernResume.Resume.CV

    @invalid_attrs %{title: nil, content: nil}

    test "list_cvs/0 returns all cvs" do
      cv = cv_fixture()
      assert Resume.list_cvs() == [cv]
    end

    test "get_cv!/1 returns the cv with given id" do
      cv = cv_fixture()
      assert Resume.get_cv(cv.id) == cv
    end

    test "create_cv/1 with valid data creates a cv" do
      valid_attrs = %{
        user_id: user_fixture().id,
        title: "some title",
        content: %{
          name: "John Doe",
          position: "Test Sample"
        }
      }

      assert {:ok, %CV{} = cv} = Resume.create_cv(valid_attrs)

      assert cv.title == "some title"
      assert cv.content.name == "John Doe"
      assert cv.content.position == "Test Sample"
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

      assert cv.content.name == "Jane Doe"
      assert cv.content.position == "Manager"
    end

    test "update_cv/2 with invalid data returns error changeset" do
      cv = cv_fixture()
      assert {:error, %Ecto.Changeset{}} = Resume.update_cv(cv, @invalid_attrs)
      assert cv == Resume.get_cv(cv.id)
    end

    test "delete_cv/1 deletes the cv" do
      cv = cv_fixture()
      assert {:ok, %CV{}} = Resume.delete_cv(cv)
      assert nil == Resume.get_cv(cv.id)
    end
  end
end
