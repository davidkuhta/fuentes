defmodule Fuentes.AccountTest do
  use Fuentes.EctoCase
  #import Fuentes.TestFactory

  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)

  alias Fuentes.TestFactory
  alias Fuentes.{Account}

  asset = TestFactory.insert(%Fuentes.Account{
      name: "My Assets",
      type: "Asset",
      contra: false
    })

  liability = TestFactory.insert(%Fuentes.Account{
      name: "Liability",
      type: "Liability",
      contra: false
    })

  equity = TestFactory.insert(%Fuentes.Account{
      name: "Owner Equity",
      type: "Equity",
      contra: false
    })

  revenue = TestFactory.insert(%Fuentes.Account{
      name: "My Revenue",
      type: "Revenue",
      contra: false
    })

  expense = TestFactory.insert(%Fuentes.Account{
      name: "My Expenses",
      type: "Expense",
      contra: false
    })

  @valid_attrs %{name: "A valid account name", type: "Asset", contra: false}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Account.changeset(%Account{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Account.changeset(%Account{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "should build an account" do
    account = TestFactory.insert(:account)
    IO.inspect account
    assert %Account{} = account
  end
end
