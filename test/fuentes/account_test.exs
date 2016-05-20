defmodule Fuentes.AccountTest do
  use Fuentes.EctoCase
  #import Fuentes.TestFactory

  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)

  alias Fuentes.TestFactory
  alias Fuentes.{Account}

  @valid_attrs %{name: "A valid account name", type: "asset", contra: false}
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
    #IO.inspect asset
    liability = TestFactory.insert(:account, name: "Liabilities", type: "liability")
    equity = TestFactory.insert(:account, name: "Equity", type: "equity")
    revenue = TestFactory.insert(:account, name: "Revenue", type: "revenue")
    expense = TestFactory.insert(:account, name: "Expense", type: "expense")
    #IO.inspect liability
    IO.inspect Fuentes.Account.trial_balance(Fuentes.TestRepo)
    assert %Account{} = asset
  end
end
