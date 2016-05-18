defmodule Fuentes.AccountTest do
  use Fuentes.EctoCase
  #import Fuentes.TestFactory

  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)

  alias Fuentes.TestFactory
  alias Fuentes.{Account}

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
    asset = TestFactory.insert(:account)
    IO.inspect asset
    liability = TestFactory.insert(:account, name: "Liabilities", type: "Liability")
    equity = TestFactory.insert(:account, name: "Equity", type: "Equity")
    revenue = TestFactory.insert(:account, name: "Revenue", type: "Revenue")
    expense = TestFactory.insert(:account, name: "Expense", type: "Expense")
    IO.inspect liability
    assert %Account{} = asset
  end
end
