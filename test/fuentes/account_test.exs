defmodule Fuentes.AccountTest do
  use Fuentes.EctoCase

  :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fuentes.TestRepo)

  import Fuentes.TestFactory
  alias Fuentes.{Account, TestRepo}

  @valid_attrs params_for(:account)
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
    asset = insert(:account)
    insert(:account, name: "Liabilities", type: "liability")
    insert(:account, name: "Revenue", type: "revenue")
    insert(:account, name: "Expense", type: "expense")
    equity = insert(:account, name: "Equity", type: "equity")
    drawing = insert(:account, name: "Drawing", type: "equity", contra: true)

    assert Account.balance(TestRepo) == Decimal.new(0.0)

    insert(:entry, amounts: [ build(:credit, account_id: asset.id),
                              build(:debit, account_id: equity.id) ])

    assert Decimal.to_integer(Account.balance(TestRepo)) == 0

    insert(:entry, amounts: [ build(:credit, account_id: equity.id),
                              build(:debit, account_id: drawing.id) ])

    assert Decimal.to_integer(Account.balance(TestRepo)) == 0

    insert(:entry, amounts: [ build(:credit, account_id: asset.id) ])

    refute Decimal.to_integer(Account.balance(TestRepo)) == 0

  end

  test "account balances with entries and dates" do
    insert(:account)
    insert(:account, name: "Liabilities", type: "liability")
    insert(:account, name: "Revenue", type: "revenue")
    insert(:account, name: "Expense", type: "expense")
    equity = insert(:account, name: "Equity", type: "equity")
    drawing = insert(:account, name: "Drawing", type: "equity", contra: true)

    insert(:entry, amounts: [ build(:credit, account_id: equity.id),
                              build(:debit, account_id: drawing.id) ])

    assert Account.balance(equity, TestRepo) ==
           Account.balance(equity, %{to_date: Ecto.DateTime.from_erl(:calendar.universal_time())}, TestRepo)

    insert(:entry, date: %Ecto.Date{ year: 2016, month: 6, day: 16 },
            amounts: [ build(:credit, account_id: equity.id),
                       build(:debit, account_id: drawing.id) ])

    refute Account.balance(equity, TestRepo) ==
           Account.balance(equity, %{to_date: Ecto.DateTime.from_erl(:calendar.universal_time())}, TestRepo)

    assert Account.balance(equity, TestRepo) ==
           Account.balance(equity, %{to_date: %Ecto.Date{ year: 2016, month: 6, day: 17 }}, TestRepo)

    refute Account.balance(equity, TestRepo) ==
           Account.balance(equity, %{to_date: %Ecto.Date{ year: 2015, month: 6, day: 17 }}, TestRepo)

  end

end
