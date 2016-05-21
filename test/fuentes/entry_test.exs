defmodule Fuentes.EntryTest do
  use Fuentes.EctoCase

  import Fuentes.TestFactory
  alias Fuentes.{ Amount, Entry }


  @valid_attrs params_for(:entry)
  @invalid_attrs %{}

  @valid_with_amount_attrs %{
    description: "Purchased a Lamborghini",
    date: %Ecto.Date{ year: 2016, month: 1, day: 16 },
    amounts: [ %Amount{ amount: Decimal.new(125000.00), type: "credit", account_id: 1},
              %Amount{ amount: Decimal.new(125000.00), type: "debit", account_id: 2}]
    }

  test "entry casts associated amounts" do
    changeset = Entry.changeset %Entry{
      description: "Buying first Porsche",
      date: %Ecto.Date{ year: 2016, month: 1, day: 16 },
      amounts: [ %Amount{ amount: Decimal.new(125000.00), type: "credit", account_id: 2 },
                 %Amount{ amount: Decimal.new(50000.00), type: "debit", account_id: 1 } ,
                 %Amount{ amount: Decimal.new(75000.00), type: "debit", account_id: 1 } ]
    }
    assert changeset.valid?
  end

  test "entry debits and credits must cancel" do
    changeset = Entry.changeset %Entry{
      description: "Buying first Porsche",
      date: %Ecto.Date{ year: 2016, month: 1, day: 16 },
      amounts: [ %Amount{ amount: Decimal.new(125000.00), type: "credit", account_id: 2 },
                 %Amount{ amount: Decimal.new(50000.00), type: "debit", account_id: 1 } ,
                 %Amount{ amount: Decimal.new(76000.00), type: "debit", account_id: 1 } ]
    }
    refute changeset.valid?
  end
end
