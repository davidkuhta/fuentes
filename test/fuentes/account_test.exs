defmodule Fuentes.AccountTest do
  use Fuentes.EctoCase
  alias Fuentes.TestRepo
  alias Fuentes.Account

  @valid_attrs %{name: "A valid account name", type: "Asset"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Account.changeset(%Account{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Account.changeset(%Account{}, @invalid_attrs)
    refute changeset.valid?
  end
end
