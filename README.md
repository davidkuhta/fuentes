# Fuentes

Fuentes is a double entry accounting system for your Elixir application.

_Work In Progress_ - use at your own risk.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add fuentes to your list of dependencies in `mix.exs`:

        def deps do
          [{:fuentes, "~> 0.0.1"}]
        end

  2. Ensure fuentes is started before your application:

        def application do
          [applications: [:fuentes]]
        end

## Overview

The Fuentes library provides a double entry accounting system for use in any Elixir application. The plugin follows general Double Entry Bookkeeping practices. All calculations are done using BigDecimal in order to prevent floating point rounding errors. The plugin requires a decimal type on your database as well.

Fuentes consists of tables that maintain your accounts, entries and debits and credits. Each entry can have many debits and credits. The entry table, which records your business transactions is, essentially, your accounting Journal.

##Accounts

The Account class represents accounts in the system. Each account must be set to one of the following types:

   TYPE        | NORMAL BALANCE    | DESCRIPTION
   --------------------------------------------------------------------------
   asset       | Debit             | Resources owned by the Business Entity
   liability   | Credit            | Debts owed to outsiders
   equity      | Credit            | Owners rights to the Assets

   Your Book of Accounts needs to be created prior to recording any entries. The simplest method is to have a number of insert methods in your priv/repo/migrations/seeds.exs file like so:
   ```
   Repo.insert! %Fuentes.Account{ name: "Cash", type: "asset" }
   Repo.insert! %Fuentes.Account{ name: "Liabilities", type: "liabilities" }
   Repo.insert! %Fuentes.Account{ name: "Owner's Equity", type: "equity" }
   ```

Each account can also be marked as a "Contra Account". A contra account will have it's
normal balance swapped. For example, to remove equity, a "Drawing" account may be created
as a contra equity account as follows:

 `account = %Fuentes.Account{ name: "Drawing", type: "asset", contra: true }`

At all times the balance of all accounts should conform to the "accounting equation"
 Assets = Liabilities + Owner's Equity

Each account type acts as it's own ledger.

#Examples

##Recording an Entry

Let's assume we're accounting on an Accrual basis. We've just purchased a company vehicle.
To record this entry we'd need two accounts:

```
entry_changeset = Fuentes.%Entry{
  description: "Purchase new company Porsche 911 GT3 RS",
  date: %Ecto.Date{ year: 2016, month: 5, day: 24 },
  amounts: [ %Amount{ amount: Decimal.new(175900.00), type: "credit", account_id: 1 },
             %Amount{ amount: Decimal.new(175900.00), type: "debit", account_id: 2 }]
}
```

Entries must specify a description, as well as at least one credit and debit amount. Specifying the date is optional.

Finally, insert the entry.

`Repo.insert!(entry_changeset)`

If there are any issues with your credit and debit amounts, the insert will fail and return false. You can inspect the changeset errors. Because we are doing double-entry accounting, the sum total of your credit and debit amounts must always cancel out to keep the accounts in balance.

### Recognition

Credit (_and debits!_) go to @mbulat and his Rails Engine [Plutus](https://github.com/mbulat/plutus) for providing the inspiration for this library.
