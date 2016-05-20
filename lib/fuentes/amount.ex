# lib/fuentes/amount.ex
defmodule Fuentes.Amount do
  @moduledoc false

  @doc ~S"""
  The Amount class represents credit amounts in the system.

  An amount must be a subclassed as either a debit or a credit to be saved to the database.

  """
  alias Fuentes.{Account, Amount}
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  schema "amounts" do
    field :amount, :decimal
    field :type, :string

    belongs_to :entry, Fuentes.Entry
    belongs_to :account, Fuentes.Account

    timestamps
  end

  @fields ~w(amount type)

  @amount_types ["credit", "debit"]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> Ecto.Changeset.assoc_constraint([:entry, :account])
    |> validate_required([:amount, :type])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> validate_inclusion(:type, @amount_types)
  end

  def for_entry(query, entry) do
    from c in query,
     join: p in assoc(c, :entry),
     where: p.id == ^entry.id
  end

  def for_account(query, account) do
    from c in query,
     join: p in assoc(c, :account),
    where: p.id == ^account.id
  end

  def sum_type(query, type) do
    from c in query,
    where: c.type == ^type,
    select: [sum(c.amount)]
  end
end
