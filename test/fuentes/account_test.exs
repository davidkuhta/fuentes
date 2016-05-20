defmodule Fuentes.AccountTest do
  use Fuentes.EctoCase
  #import Fuentes.TestFactory

  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)

  alias Fuentes.TestFactory
  alias Fuentes.{Account, TestRepo}

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

  test "trial balance zero with and without entries" do
    TestFactory.insert(:account)
    TestFactory.insert(:account, name: "Liabilities", type: "liability")
    TestFactory.insert(:account, name: "Equity", type: "equity")
    TestFactory.insert(:account, name: "Revenue", type: "revenue")
    TestFactory.insert(:account, name: "Expense", type: "expense")

    pristine_balance = Account.trial_balance(TestRepo)
    assert pristine_balance == Decimal.new(0.0)

    TestFactory.insert(:entry)

    entried_balance = Decimal.to_integer(Account.trial_balance(TestRepo))
    assert entried_balance == 0

    TestFactory.insert(:entry, amounts: [ TestFactory.build(:credit) ])
    unbalanced = Decimal.to_integer(Account.trial_balance(TestRepo))
    refute unbalanced == 0
  end

end
