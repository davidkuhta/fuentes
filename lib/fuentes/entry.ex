# lib/fuentes/account.ex
defmodule Fuentes.Entry do
  use Ecto.Schema
  import Ecto
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  schema "entries" do
    field :description, :string
    field :date, Ecto.Date

    has_many :debit_amounts, Fuentes.DebitAmount, on_delete: :delete_all
    has_many :credit_amounts, Fuentes.CreditAmount, on_delete: :delete_all

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
    |> cast_assoc(:credit_amounts)
    |> cast_assoc(:debit_amounts)
  end

  def credit_amounts(entry) do
    from amount in Fuentes.CreditAmount,
     join: entry in assoc(amount, :entry)
  end

  def debit_amounts(entry) do
    from amount in Fuentes.DebitAmount,
     join: entry in assoc(amount, :entry)
  end

  def credit_sum(entry) do
    from amount in Fuentes.CreditAmount,
     join: entry in assoc(amount, :entry),
     select: [sum(amount.amount)]
  end

  def debit_sum(entry) do
    from amount in Fuentes.DebitAmount,
     join: entry in assoc(amount, :entry),
     select: [sum(amount.amount)]
  end

  def validate_sum_zero(changeset) do
    IO.inspect changeset
  end

end
