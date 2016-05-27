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

  @typedoc """
  Just a number followed by a string.
  """
  @type fuentes_account :: {number, String.t}

  alias Fuentes.{ Account, Amount, Config }

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
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, @credit_types ++ @debit_types)
  end

  def with_amounts(query) do
    from q in query, preload: [:amounts]
  end

  def amount_sum(repo, account, type) do
    [sum] = Amount |> Amount.for_account(account) |> Amount.sum_type(type) |> repo.all

    if sum do
      sum
    else
      Decimal.new(0)
    end
  end

  def amount_sum(repo, account, type, dates) do
    [sum] =
    Amount |> Amount.for_account(account) |> Amount.dated(dates) |> Amount.sum_type(type) |> repo.all

    if sum do
      sum
    else
      Decimal.new(0)
    end
  end

  def balance(repo \\ Config.repo_from_config, accounts)

  # Balance for list of accounts, intended for use when of the same account type.
  def balance(repo, accounts) when is_list(accounts) do
    Enum.reduce(accounts, Decimal.new(0.0), fn(account, acc) ->
       Decimal.add( Account.balance(repo, account), acc)
    end)
  end

  # Balance for individual account
  def balance(repo, account = %Account { type: type, contra: contra }) do
    credits = Account.amount_sum(repo, account, "credit")
    debits =  Account.amount_sum(repo, account, "debit")

    if type in @credit_types && !(contra) do
      balance = Decimal.sub(debits, credits)
    else
      balance = Decimal.sub(credits, debits)
    end
  end

  # Balance for individual account with dates
  def balance(repo, account = %Account { type: type, contra: contra }, dates) do
    credits = Account.amount_sum(repo, account, "credit", dates)
    debits =  Account.amount_sum(repo, account, "debit", dates)

    if type in @credit_types && !(contra) do
      balance = Decimal.sub(debits, credits)
    else
      balance = Decimal.sub(credits, debits)
    end
  end

  # Trial Balance for all accounts
  def trial_balance(repo \\ Config.repo_from_config) do
    accounts = repo.all(Account)
    accounts_by_type = Enum.group_by(accounts, fn(i) -> String.to_atom(i.type) end)

    accounts_by_type = Enum.map(accounts_by_type, fn { account_type, accounts } ->
      { account_type, Account.balance(repo, accounts) }
    end)

    accounts_by_type[:asset]
    |> Decimal.sub(accounts_by_type[:liability])
    |> Decimal.sub(accounts_by_type[:equity])
    |> Decimal.sub(accounts_by_type[:revenue])
    |> Decimal.add(accounts_by_type[:expense])
  end
end
