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
alias Fuentes.Repo
alias Fuentes.Account
alias Fuentes.Entry
alias Fuentes.Amount

account1_changeset = Account.changeset(%Account{}, %{
  name: "Cash",
  type: "Asset"
  })


account2_changeset = Account.changeset(%Account{}, %{
  name: "Loan",
  name: "Liability"
  })

account3_changeset = Account.changeset(%Account{}, %{
  name: "David",
  name: "Equity"
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

amount1 = Repo.insert! %Amount{
  type: "Credit",
  amount: Decimal.new(2400.00),
  account_id: 1,
  entry_id: 1
}

amount2 = Repo.insert! %Amount{
  type: "Debit",
  amount: Decimal.new(2400.00),
  account_id: 2,
  entry_id: 1
}
