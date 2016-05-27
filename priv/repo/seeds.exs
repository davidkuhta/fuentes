# Sample script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# Repositories directly:
#
#     Fuentes.Repo.insert!(%Fuentes.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# alias Fuentes.{Account, Entry, Amount}
# alias Fuentes.Repo
#
# account1_changeset = Account.changeset(%Account{}, %{
#   name: "Cash",
#   type: "asset"
#   })
#
#
# account2_changeset = Account.changeset(%Account{}, %{
#   name: "Loan",
#   type: "liability"
#   })
#
# account3_changeset = Account.changeset(%Account{}, %{
#   name: "David",
#   type: "equity"
#   })
#
# cash = Repo.insert!(account1_changeset)
# loan = Repo.insert!(account2_changeset)
# david = Repo.insert!(account3_changeset)
#
#
# entry1 = Repo.insert! %Entry{
#   description: "Initial Deposit",
#   date: %Ecto.Date{ year: 2016, month: 1, day: 14 }
# }
#
# entry2 = Repo.insert! %Entry{
#   description: "Purchased paper",
#   date: %Ecto.Date{ year: 2016, month: 1, day: 15 }
# }
#
# entry2 = Repo.insert! %Entry{
#   description: "Sold Asset",
#   date: %Ecto.Date{ year: 2016, month: 1, day: 16 }
# }
#
# amount1 = Repo.insert! %Amount{
#   amount: Decimal.new(2400.00),
#   type: "credit",
#   account_id: 1,
#   entry_id: 1
# }
#
# amount2 = Repo.insert! %Amount{
#   amount: Decimal.new(2400.00),
#   type: "debit",
#   account_id: 2,
#   entry_id: 1
# }
#
# changeset = Entry.changeset %Entry{
#   description: "Buying first Porsche",
#   date: %Ecto.Date{ year: 2016, month: 1, day: 16 },
#   amounts: [ %Amount{ amount: Decimal.new(125000.00), type: "credit", account_id: 2 },
#              %Amount{ amount: Decimal.new(50000.00), type: "debit", account_id: 1 } ,
#              %Amount{ amount: Decimal.new(75000.00), type: "debit", account_id: 1 } ]
# }
#
# IO.inspect changeset
# IO.inspect changeset.valid?
# Repo.insert!(changeset)
#
# Repo.insert! %Entry{
#   description: "Buying first G6",
#   date: %Ecto.Date{ year: 2016, month: 1, day: 16 },
#   amounts: [ %Amount{ amount: Decimal.new(1250000.00), type: "credit", account_id: 2 },
#              %Amount{ amount: Decimal.new(500000.00), type: "debit", account_id: 1 } ,
#              %Amount{ amount: Decimal.new(705000.00), type: "debit", account_id: 1 } ]
# }
