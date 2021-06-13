#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule Pento.SurveyTest do
  use Pento.DataCase

  alias Pento.Survey

  describe "demographics" do
    alias Pento.Survey.Demographic

    @valid_attrs %{
      Satisfaction: "some Satisfaction",
      gender: "some gender",
      satisfied: true,
      year_of_birth: ~D[2010-04-17]
    }
    @update_attrs %{
      Satisfaction: "some updated Satisfaction",
      gender: "some updated gender",
      satisfied: false,
      year_of_birth: ~D[2011-05-18]
    }
    @invalid_attrs %{Satisfaction: nil, gender: nil, satisfied: nil, year_of_birth: nil}

    def demographic_fixture(attrs \\ %{}) do
      {:ok, demographic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Survey.create_demographic()

      demographic
    end

    test "list_demographics/0 returns all demographics" do
      demographic = demographic_fixture()
      assert Survey.list_demographics() == [demographic]
    end

    test "get_demographic!/1 returns the demographic with given id" do
      demographic = demographic_fixture()
      assert Survey.get_demographic!(demographic.id) == demographic
    end

    test "create_demographic/1 with valid data creates a demographic" do
      assert {:ok, %Demographic{} = demographic} = Survey.create_demographic(@valid_attrs)
      assert demographic.Satisfaction == "some Satisfaction"
      assert demographic.gender == "some gender"
      assert demographic.satisfied == true
      assert demographic.year_of_birth == ~D[2010-04-17]
    end

    test "create_demographic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Survey.create_demographic(@invalid_attrs)
    end

    test "update_demographic/2 with valid data updates the demographic" do
      demographic = demographic_fixture()

      assert {:ok, %Demographic{} = demographic} =
               Survey.update_demographic(demographic, @update_attrs)

      assert demographic.Satisfaction == "some updated Satisfaction"
      assert demographic.gender == "some updated gender"
      assert demographic.satisfied == false
      assert demographic.year_of_birth == ~D[2011-05-18]
    end

    test "update_demographic/2 with invalid data returns error changeset" do
      demographic = demographic_fixture()
      assert {:error, %Ecto.Changeset{}} = Survey.update_demographic(demographic, @invalid_attrs)
      assert demographic == Survey.get_demographic!(demographic.id)
    end

    test "delete_demographic/1 deletes the demographic" do
      demographic = demographic_fixture()
      assert {:ok, %Demographic{}} = Survey.delete_demographic(demographic)
      assert_raise Ecto.NoResultsError, fn -> Survey.get_demographic!(demographic.id) end
    end

    test "change_demographic/1 returns a demographic changeset" do
      demographic = demographic_fixture()
      assert %Ecto.Changeset{} = Survey.change_demographic(demographic)
    end
  end

  describe "demographics" do
    alias Pento.Survey.Demographic

    @valid_attrs %{
      Satisfaction: "some Satisfaction",
      gender: "some gender",
      satisfactions: "some satisfactions",
      satisfied: true,
      year_of_birth: ~D[2010-04-17]
    }
    @update_attrs %{
      Satisfaction: "some updated Satisfaction",
      gender: "some updated gender",
      satisfactions: "some updated satisfactions",
      satisfied: false,
      year_of_birth: ~D[2011-05-18]
    }
    @invalid_attrs %{
      Satisfaction: nil,
      gender: nil,
      satisfactions: nil,
      satisfied: nil,
      year_of_birth: nil
    }

    def demographic_fixture(attrs \\ %{}) do
      {:ok, demographic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Survey.create_demographic()

      demographic
    end

    test "list_demographics/0 returns all demographics" do
      demographic = demographic_fixture()
      assert Survey.list_demographics() == [demographic]
    end

    test "get_demographic!/1 returns the demographic with given id" do
      demographic = demographic_fixture()
      assert Survey.get_demographic!(demographic.id) == demographic
    end

    test "create_demographic/1 with valid data creates a demographic" do
      assert {:ok, %Demographic{} = demographic} = Survey.create_demographic(@valid_attrs)
      assert demographic.Satisfaction == "some Satisfaction"
      assert demographic.gender == "some gender"
      assert demographic.satisfactions == "some satisfactions"
      assert demographic.satisfied == true
      assert demographic.year_of_birth == ~D[2010-04-17]
    end

    test "create_demographic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Survey.create_demographic(@invalid_attrs)
    end

    test "update_demographic/2 with valid data updates the demographic" do
      demographic = demographic_fixture()

      assert {:ok, %Demographic{} = demographic} =
               Survey.update_demographic(demographic, @update_attrs)

      assert demographic.Satisfaction == "some updated Satisfaction"
      assert demographic.gender == "some updated gender"
      assert demographic.satisfactions == "some updated satisfactions"
      assert demographic.satisfied == false
      assert demographic.year_of_birth == ~D[2011-05-18]
    end

    test "update_demographic/2 with invalid data returns error changeset" do
      demographic = demographic_fixture()
      assert {:error, %Ecto.Changeset{}} = Survey.update_demographic(demographic, @invalid_attrs)
      assert demographic == Survey.get_demographic!(demographic.id)
    end

    test "delete_demographic/1 deletes the demographic" do
      demographic = demographic_fixture()
      assert {:ok, %Demographic{}} = Survey.delete_demographic(demographic)
      assert_raise Ecto.NoResultsError, fn -> Survey.get_demographic!(demographic.id) end
    end

    test "change_demographic/1 returns a demographic changeset" do
      demographic = demographic_fixture()
      assert %Ecto.Changeset{} = Survey.change_demographic(demographic)
    end
  end

  describe "demographics" do
    alias Pento.Survey.Demographic

    @valid_attrs %{gender: "some gender", year_of_birth: ~D[2010-04-17]}
    @update_attrs %{gender: "some updated gender", year_of_birth: ~D[2011-05-18]}
    @invalid_attrs %{gender: nil, year_of_birth: nil}

    def demographic_fixture(attrs \\ %{}) do
      {:ok, demographic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Survey.create_demographic()

      demographic
    end

    test "list_demographics/0 returns all demographics" do
      demographic = demographic_fixture()
      assert Survey.list_demographics() == [demographic]
    end

    test "get_demographic!/1 returns the demographic with given id" do
      demographic = demographic_fixture()
      assert Survey.get_demographic!(demographic.id) == demographic
    end

    test "create_demographic/1 with valid data creates a demographic" do
      assert {:ok, %Demographic{} = demographic} = Survey.create_demographic(@valid_attrs)
      assert demographic.gender == "some gender"
      assert demographic.year_of_birth == ~D[2010-04-17]
    end

    test "create_demographic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Survey.create_demographic(@invalid_attrs)
    end

    test "update_demographic/2 with valid data updates the demographic" do
      demographic = demographic_fixture()

      assert {:ok, %Demographic{} = demographic} =
               Survey.update_demographic(demographic, @update_attrs)

      assert demographic.gender == "some updated gender"
      assert demographic.year_of_birth == ~D[2011-05-18]
    end

    test "update_demographic/2 with invalid data returns error changeset" do
      demographic = demographic_fixture()
      assert {:error, %Ecto.Changeset{}} = Survey.update_demographic(demographic, @invalid_attrs)
      assert demographic == Survey.get_demographic!(demographic.id)
    end

    test "delete_demographic/1 deletes the demographic" do
      demographic = demographic_fixture()
      assert {:ok, %Demographic{}} = Survey.delete_demographic(demographic)
      assert_raise Ecto.NoResultsError, fn -> Survey.get_demographic!(demographic.id) end
    end

    test "change_demographic/1 returns a demographic changeset" do
      demographic = demographic_fixture()
      assert %Ecto.Changeset{} = Survey.change_demographic(demographic)
    end
  end

  describe "satisfactions" do
    alias Pento.Survey.Satisfaction

    @valid_attrs %{satisfied: true}
    @update_attrs %{satisfied: false}
    @invalid_attrs %{satisfied: nil}

    def satisfaction_fixture(attrs \\ %{}) do
      {:ok, satisfaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Survey.create_satisfaction()

      satisfaction
    end

    test "list_satisfactions/0 returns all satisfactions" do
      satisfaction = satisfaction_fixture()
      assert Survey.list_satisfactions() == [satisfaction]
    end

    test "get_satisfaction!/1 returns the satisfaction with given id" do
      satisfaction = satisfaction_fixture()
      assert Survey.get_satisfaction!(satisfaction.id) == satisfaction
    end

    test "create_satisfaction/1 with valid data creates a satisfaction" do
      assert {:ok, %Satisfaction{} = satisfaction} = Survey.create_satisfaction(@valid_attrs)
      assert satisfaction.satisfied == true
    end

    test "create_satisfaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Survey.create_satisfaction(@invalid_attrs)
    end

    test "update_satisfaction/2 with valid data updates the satisfaction" do
      satisfaction = satisfaction_fixture()

      assert {:ok, %Satisfaction{} = satisfaction} =
               Survey.update_satisfaction(satisfaction, @update_attrs)

      assert satisfaction.satisfied == false
    end

    test "update_satisfaction/2 with invalid data returns error changeset" do
      satisfaction = satisfaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Survey.update_satisfaction(satisfaction, @invalid_attrs)

      assert satisfaction == Survey.get_satisfaction!(satisfaction.id)
    end

    test "delete_satisfaction/1 deletes the satisfaction" do
      satisfaction = satisfaction_fixture()
      assert {:ok, %Satisfaction{}} = Survey.delete_satisfaction(satisfaction)
      assert_raise Ecto.NoResultsError, fn -> Survey.get_satisfaction!(satisfaction.id) end
    end

    test "change_satisfaction/1 returns a satisfaction changeset" do
      satisfaction = satisfaction_fixture()
      assert %Ecto.Changeset{} = Survey.change_satisfaction(satisfaction)
    end
  end
end
