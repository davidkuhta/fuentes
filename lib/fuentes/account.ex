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

    has_many :debit_amounts, Fuentes.DebitAmount, on_delete: :delete_all
    has_many :credit_amounts, Fuentes.CreditAmount, on_delete: :delete_all

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

  def balance(account = %Account { type: "Asset" }) do
    credits = Account
      |> Account.credit_sum
      |> Repo.get(account.id)

    debits = Account
      |> Account.debit_sum
      |> Repo.get(account.id)

    credits - debits
  end

  def balance(account) do
      debit_sum(account) - credit_sum(account)
  end

  def with_amounts(query) do
    from q in query, preload: [:credit_amounts, :debit_amounts]
  end

  def sum(account) do
    #from amount in Fuentes.Amount, join: account in assoc(amount, :account), select: [sum(amount.amount)]
  end

  # Account |> Account.credit_sum |> Repo.get(1) [Repo.get(Account.credit_sum(Account),1)]
  def credit_sum(account = %Account{}) do
    from amount in Fuentes.CreditAmount,
     where: amount.account_id == ^account.id,
     #join: account in assoc(amount, :account),
     #where: amount.type == "Credit",
     select: [sum(amount.amount)]
  end

  def debit_sum(account = %Account{}) do
    from amount in Fuentes.DebitAmount,
      where: amount.account_id == ^account.id,
      #join: account in assoc(amount, :account),
      #where: amount.type == "Debit",
      select: [sum(amount.amount)]
  end
end
