# lib/fuentes/account.ex
defmodule Fuentes.Account do
  alias Fuentes.Account
  @moduledoc false

  @doc ~S"""
  The Account class represents accounts in the system. Each account must be subclassed as one of the following types:

     TYPE        | NORMAL BALANCE    | DESCRIPTION
     --------------------------------------------------------------------------
     Asset       | Debit             | Resources owned by the Business Entity
     Liability   | Credit            | Debts owed to outsiders
     Equity      | Credit            | Owners rights to the Assets
     Revenue     | Credit            | Increases in owners equity
     Expense     | Debit             | Assets or services consumed in the generation of revenue

   Each account can also be marked as a "Contra Account". A contra account will have it's
   normal balance swapped. For example, to remove equity, a "Drawing" account may be created
   as a contra equity account as follows:

     account = %Fuentes.Account{name: "Cash", type: "Asset", contra: false}

   At all times the balance of all accounts should conform to the "accounting equation"
     Assets = Liabilties + Owner's Equity

   Each subclass account acts as it's own ledger. See the individual subclasses for a
   description.

   @abstract
     An account must be a subclass to be saved to the database. The Account class
     has a singleton method {trial_balance} to calculate the balance on all Accounts.

   @see http://en.wikipedia.org/wiki/Accounting_equation Accounting Equation
   @see http://en.wikipedia.org/wiki/Debits_and_credits Debits, Credits, and Contra Accounts

  """

  use Ecto.Schema
  import Ecto
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  schema "accounts" do
    field :name, :string
    field :type, :string
    field :contra, :boolean, default: false
    field :balance, :decimal, virtual: true

    has_many :amounts, Fuentes.Amount, on_delete: :delete_all
    # has_many :debit_amounts, Fuentes.DebitAmount, on_delete: :delete_all
    # has_many :credit_amounts, Fuentes.CreditAmount, on_delete: :delete_all

    timestamps
  end

  @fields ~w(name type contra)

  @account_types ["Asset", "Liability", "Equity", "Revenue", "Expense"]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, @account_types)
  end

  def balance(account = %Account { type: type, contra: contra }, repo) do
    credits = Account.credit_sum(account, repo)
    debits =  Account.debit_sum(account, repo)

    if type in ["Asset", "Expense"] && !(contra) do
      balance = Decimal.sub(debits, credits)
    else
      balance = Decimal.sub(credits, debits)
    end
  end

  def with_amounts(query) do
    from q in query, preload: [:credit_amounts, :debit_amounts]
  end

  def credit_sum(account = %Account{}, repo) do
    [credit_sum] = account |> Account.credit_sum_query |> repo.all

    if credit_sum do
      credit_sum
    else
      Decimal.new(0)
    end
  end

  def debit_sum(account = %Account{}, repo) do
    [debit_sum] = account |> Account.debit_sum_query |> repo.all

    if debit_sum do
      debit_sum
    else
      Decimal.new(0)
    end
  end

  # Account |> Account.credit_sum |> Repo.get(1) [Repo.get(Account.credit_sum(Account),1)]
  def credit_sum_query(account = %Account{}) do
    from amount in Fuentes.Amount,
     where: amount.account_id == ^account.id,
     #join: account in assoc(amount, :account),
     where: amount.type == "credit",
     select: sum(amount.amount)
  end

  def debit_sum_query(account = %Account{}) do
    from amount in Fuentes.Amount,
      where: amount.account_id == ^account.id,
      #join: account in assoc(amount, :account),
      where: amount.type == "debit",
      select: sum(amount.amount)
  end

  def trial_balance(repo) do
      accounts = repo.all(Fuentes.Account)
      accounts = Enum.group_by(accounts, fn(i) -> i.type end)
      
      asset_sum = Enum.reduce(accounts["Asset"], Decimal.new(0.0), fn(i, acc) -> Decimal.add(Fuentes.balance(i, repo), acc) end)
      liability_sum = Enum.reduce(accounts["Liability"], Decimal.new(0.0), fn(i, acc) -> Decimal.add(Fuentes.balance(i, repo), acc) end)
      equity_sum = Enum.reduce(accounts["Equity"], Decimal.new(0.0), fn(i, acc) -> Decimal.add(Fuentes.balance(i, repo), acc) end)
      revenue_sum = Enum.reduce(accounts["Revenue"], Decimal.new(0.0), fn(i, acc) -> Decimal.add(Fuentes.balance(i, repo), acc) end)
      expense_sum = Enum.reduce(accounts["Expense"], Decimal.new(0.0), fn(i, acc) -> Decimal.add(Fuentes.balance(i, repo), acc) end)

      trial_balance = asset_sum - (liability_sum + equity_sum + revenue_sum - expense_sum)
  end
end
