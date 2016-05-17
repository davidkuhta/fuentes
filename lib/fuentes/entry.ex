# lib/fuentes/account.ex
defmodule Fuentes.Entry do
  use Ecto.Schema
  import Ecto
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  schema "entries" do
    field :description, :string
    field :date, Ecto.Date

    has_many :amounts, Fuentes.Amount, on_delete: :delete_all

    # has_many :debit_amounts, Fuentes.DebitAmount, on_delete: :delete_all
    # has_many :credit_amounts, Fuentes.CreditAmount, on_delete: :delete_all

    timestamps
  end

  @fields ~w(description date)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required([:description, :date])
    |> cast_assoc(:amounts)
    |> validate_debits_and_credits_balance
  end

  def credit_amounts(entry) do
    from amount in Fuentes.Amount,
     join: entry in assoc(amount, :entry),
     where: amount.type == "credit"
  end

  def debit_amounts(entry) do
    from amount in Fuentes.Amount,
     join: entry in assoc(amount, :entry),
     where: amount.type == "debit"
  end

  def credit_sum(entry) do
    from amount in Fuentes.CreditAmount,
     join: entry in assoc(amount, :entry),
     where: amount.type == "credit",
     select: [sum(amount.amount)]
  end

  def debit_sum(entry) do
    from amount in Fuentes.DebitAmount,
     join: entry in assoc(amount, :entry),
     where: amount.type == "debit",
     select: [sum(amount.amount)]
  end

  def validate_debits_and_credits_balance(changeset) do
    amounts = Ecto.Changeset.get_field(changeset, :amounts)
    amounts = Enum.group_by(amounts, fn(i) -> i.type end)

    credit_sum = Enum.reduce(amounts["credit"], Decimal.new(0.0), fn(i, acc) -> Decimal.add(i.amount,acc) end )
    debit_sum = Enum.reduce(amounts["debit"], Decimal.new(0.0), fn(i, acc) -> Decimal.add(i.amount,acc) end )

    if credit_sum == debit_sum do
      changeset
    else
      add_error(changeset, :amounts, "Credit and Debit amounts must be equal")
    end
  end

end
