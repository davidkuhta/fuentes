# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fuentes.Repo.insert!(%Fuentes.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Fuentes.Account
alias Fuentes.Entry
alias Fuentes.CreditAmount
alias Fuentes.DebitAmount

account1_changeset = Account.changeset(%Account{}, %{
  name: "Cash",
  type: "Asset"
  })


account2_changeset = Account.changeset(%Account{}, %{
  name: "Loan",
  type: "Liability"
  })

account3_changeset = Account.changeset(%Account{}, %{
  name: "David",
  type: "Equity"
  })

cash = Repo.insert!(account1_changeset)
loan = Repo.insert!(account2_changeset)
david = Repo.insert!(account3_changeset)


entry1 = Repo.insert! %Entry{
  description: "Intial Deposit",
  date: %Ecto.Date{ year: 2016, month: 1, day: 14 }
}

entry2 = Repo.insert! %Entry{
  description: "Purchased paper",
  date: %Ecto.Date{ year: 2016, month: 1, day: 15 }
}

entry2 = Repo.insert! %Entry{
  description: "Sold Asset",
  date: %Ecto.Date{ year: 2016, month: 1, day: 16 }
}

amount1 = Repo.insert! %CreditAmount{
  amount: Decimal.new(2400.00),
  account_id: 1,
  entry_id: 1
}

amount2 = Repo.insert! %DebitAmount{
  amount: Decimal.new(2400.00),
  account_id: 2,
  entry_id: 1
}

changeset = Entry.changeset %Entry{
  description: "Buying first Porsche",
  date: %Ecto.Date{ year: 2016, month: 1, day: 16 },
  debit_amounts: [ %DebitAmount{ amount: Decimal.new(300.00), account_id: 2 }  ],
  credit_amounts: [ %CreditAmount{ amount: Decimal.new(300.00), account_id: 1 }  ]
}

IO.inspect changeset
IO.inspect changeset.valid?
Repo.insert!(changeset)

Repo.insert! %Entry{
  description: "Buying first G6",
  date: %Ecto.Date{ year: 2016, month: 1, day: 16 },
  debit_amounts:
    [ %DebitAmount{ amount: Decimal.new(500.00), account_id: 2 } ],
  debit_amounts:
    [ %CreditAmount{ amount: Decimal.new(500.00), account_id: 1 } ]
}
