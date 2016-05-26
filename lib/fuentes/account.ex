# lib/fuentes/account.ex
defmodule Fuentes.Account do
  @moduledoc """
  The Account class represents accounts in the system. Each account must be set to one of the following types:

     TYPE        | NORMAL BALANCE    | DESCRIPTION
     --------------------------------------------------------------------------
     asset       | Debit             | Resources owned by the Business Entity
     liability   | Credit            | Debts owed to outsiders
     equity      | Credit            | Owners rights to the Assets

   Each account can also be marked as a "Contra Account". A contra account will have it's
   normal balance swapped. For example, to remove equity, a "Drawing" account may be created
   as a contra equity account as follows:

     account = %Fuentes.Account{name: "Drawing", type: "asset", contra: true}

   At all times the balance of all accounts should conform to the "accounting equation"
     Assets = Liabilities + Owner's Equity

   Each account type acts as it's own ledger.

  For more details see:
  [Wikipedia - Accounting Equation](http://en.wikipedia.org/wiki/Accounting_equation)
  [Wikipedia - Debits, Credits, and Contra Accounts](http://en.wikipedia.org/wiki/Debits_and_credits)
  """

  alias Fuentes.{ Account, Amount }

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  schema "accounts" do
    field :name, :string
    field :type, :string
    field :contra, :boolean, default: false
    field :balance, :decimal, virtual: true

    has_many :amounts, Fuentes.Amount, on_delete: :delete_all

    timestamps
  end

  @fields ~w(name type contra)

  @credit_types ["asset"]
  @debit_types ["liability", "equity"]

  @doc """
  Creates a changeset requiring a `:name` and `:type`
  """

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, @credit_types ++ @debit_types)
  end

  defp with_amounts(query) do
    from q in query, preload: [:amounts]
  end

  @doc false
  def amount_sum(account, type, repo) do
    [sum] = Amount |> Amount.for_account(account) |> Amount.sum_type(type) |> repo.all

    if sum do
      sum
    else
      Decimal.new(0)
    end
  end

  @doc false
  def amount_sum(account, type, dates, repo) do
    [sum] =
    Amount |> Amount.for_account(account) |> Amount.dated(dates) |> Amount.sum_type(type) |> repo.all

    if sum do
      sum
    else
      Decimal.new(0)
    end
  end

  @doc """
  `balance/3 provides the account balance for a given `Fuentes.Account` in a given
  Ecto.Repo when provided with a map of dates in the format `%{from_date: from_date, to_date: to_date}`.
  """
  # Balance for individual account with dates
  def balance(account = %Account { type: type, contra: contra }, dates, repo) do
    credits = Account.amount_sum(account, "credit", dates, repo)
    debits =  Account.amount_sum(account, "debit", dates, repo)

    if type in @credit_types && !(contra) do
      balance = Decimal.sub(debits, credits)
    else
      balance = Decimal.sub(credits, debits)
    end
  end

  @doc """
  `balance/2 provides the account balance for a list of `Fuentes.Account` in a given
  Ecto.Repo inclusive of all entries. This function is intended to be used with a
  list of `Fuentes.Accounts` of the same type.
  """
  # Balance for individual account
  def balance(account = %Account { type: type, contra: contra }, repo) do
    credits = Account.amount_sum(account, "credit", repo)
    debits =  Account.amount_sum(account, "debit", repo)

    if type in @credit_types && !(contra) do
      balance = Decimal.sub(debits, credits)
    else
      balance = Decimal.sub(credits, debits)
    end
  end

  # Balance for list of accounts, intended for use when of the same account type.
  def balance(accounts, repo) when is_list(accounts) do
    Enum.reduce(accounts, Decimal.new(0.0), fn(account, acc) ->
       Decimal.add( Account.balance(account, repo), acc)
    end)
  end

  @doc """
  `balance/1` provides the trial balance for all accounts in a given Ecto.Repo.
  """
  # Trial Balance for all accounts
  def balance(repo) do
    accounts = repo.all(Account)
    accounts_by_type = Enum.group_by(accounts, fn(i) -> String.to_atom(i.type) end)

    accounts_by_type = Enum.map(accounts_by_type, fn { account_type, accounts } ->
      { account_type, Account.balance(accounts, repo) }
    end)

    accounts_by_type[:asset]
    |> Decimal.sub(accounts_by_type[:liability])
    |> Decimal.sub(accounts_by_type[:equity])
  end
end
