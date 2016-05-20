# lib/fuentes/account.ex
defmodule Fuentes.Account do
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
  alias Fuentes.{ Account, Amount}

  use Ecto.Schema
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

  @credit_types ["asset", "expense"]
  @debit_types ["liability", "equity", "revenue"]

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

  def sum_query(account = %Account{}, type) do
    from amount in Amount,
    where: amount.account_id == ^account.id,
    where: amount.type == ^type,
    select: sum(amount.amount)
  end

  def amount_sum(account, type, repo) do
    [sum] = account |> Account.sum_query(type) |> repo.all

    if sum do
      sum
    else
      Decimal.new(0)
    end
  end

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
      |> Decimal.sub(accounts_by_type[:revenue])
      |> Decimal.add(accounts_by_type[:expense])
  end
end
