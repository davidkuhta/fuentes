# lib/fuentes/account.ex
defmodule Fuentes.Account do
  @moduledoc """
  The Account module represents accounts in the system which are of _asset_,
  _liability_, or _equity_ types, in accordance with the "accounting equation".

  Each account must be set to one of the following types:

     | TYPE      | NORMAL BALANCE | DESCRIPTION                            |
     | :-------- | :-------------:| :--------------------------------------|
     | asset     | Debit          | Resources owned by the Business Entity |
     | liability | Credit         | Debts owed to outsiders                |
     | equity    | Credit         | Owners rights to the Assets            |

   Each account can also be marked as a _Contra Account_. A contra account will have it's
   normal balance swapped. For example, to remove equity, a "Drawing" account may be created
   as a contra equity account as follows:

     `account = %Fuentes.Account{name: "Drawing", type: "asset", contra: true}`

   At all times the balance of all accounts should conform to the "accounting equation"

     *Assets = Liabilities + Owner's Equity*

   Each account type acts as it's own ledger.

  For more details see:

  [Wikipedia - Accounting Equation](http://en.wikipedia.org/wiki/Accounting_equation)
  [Wikipedia - Debits, Credits, and Contra Accounts](http://en.wikipedia.org/wiki/Debits_and_credits)
  """

  @type t :: %__MODULE__{
    name: String.t,
    type: String.t,
    contra: Boolean.t,
    amounts: [Fuentes.Amount]
  }

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
  @spec amount_sum(Ecto.Repo.t, Fuentes.Account.t, String.t) :: Decimal.t
  def amount_sum(repo, account, type) do
    [sum] = Amount |> Amount.for_account(account) |> Amount.sum_type(type) |> repo.all

    if sum do
      sum
    else
      Decimal.new(0)
    end
  end

  @doc false
  @spec amount_sum(Ecto.Repo.t, Fuentes.Account.t, String.t, map) :: Decimal.t
  def amount_sum(repo, account, type, dates) do
    [sum] =
    Amount |> Amount.for_account(account) |> Amount.dated(dates) |> Amount.sum_type(type) |> repo.all

    if sum do
      sum
    else
      Decimal.new(0)
    end
  end

  @doc """
  Computes the account balance for a given `Fuentes.Account` in a given
  Ecto.Repo when provided with a map of dates in the format
  `%{from_date: from_date, to_date: to_date}`.
  Returns Decimal type.
  """

  @spec balance(Ecto.Repo.t, [Fuentes.Account.t], Ecto.Date.t) :: Decimal.t
  def balance(repo \\ Config.repo, account_or_account_list, dates \\ nil)

  # Balance for individual account
  def balance(repo, account = %Account { type: type, contra: contra }, dates) when is_nil(dates) do
    credits = Account.amount_sum(repo, account, "credit")
    debits =  Account.amount_sum(repo, account, "debit")

    if type in @credit_types && !(contra) do
      balance = Decimal.sub(debits, credits)
    else
      balance = Decimal.sub(credits, debits)
    end
  end

  @doc """
  Computes the account balance for a list of `Fuentes.Account` in a given
  Ecto.Repo inclusive of all entries. This function is intended to be used with a
  list of `Fuentes.Account`s of the same type.
  Returns Decimal type.
  """
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

  # Balance for list of accounts, intended for use when of the same account type.
  def balance(repo, accounts, dates) when is_list(accounts) do
    Enum.reduce(accounts, Decimal.new(0.0), fn(account, acc) ->
       Decimal.add( Account.balance(repo, account, dates), acc)
    end)
  end

  @doc """
  Computes the trial balance for all accounts in the provided Ecto.Repo.
  Returns Decimal type.
  """
  # Trial Balance for all accounts
  @spec trial_balance(Ecto.Repo.t) :: Decimal.t
  def trial_balance(repo \\ Config.repo_from_config) do
    accounts = repo.all(Account)
    accounts_by_type = Enum.group_by(accounts, fn(i) -> String.to_atom(i.type) end)

    accounts_by_type = Enum.map(accounts_by_type, fn { account_type, accounts } ->
      { account_type, Account.balance(repo, accounts) }
    end)

    accounts_by_type[:asset]
    |> Decimal.sub(accounts_by_type[:liability])
    |> Decimal.sub(accounts_by_type[:equity])
  end
end
