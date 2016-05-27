# lib/fuentes/account.ex
defmodule Fuentes.Entry do
  @moduledoc """
  Entries are the recording of account debits and credits and can be considered
  as consituting a traditional accounting Journal.
  """

  @type t :: %__MODULE__{
    description: String.t,
    date: Ecto.Date.t
  }

  alias Fuentes.{ Amount, Entry }

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  schema "entries" do
    field :description, :string
    field :date, Ecto.Date

    has_many :amounts, Fuentes.Amount, on_delete: :delete_all

    timestamps
  end

  @fields ~w(description date)

  @doc """
  Creates a changeset for `Fuentes.Entry`, validating a required `:description` and `:date`,
  casting an provided "debit" and "credit" `Fuentes.Amount`s, and validating that
  those amounts balance.
  """

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required([:description, :date])
    |> cast_assoc(:amounts)
    |> validate_debits_and_credits_balance
  end

  @doc """
  Accepts and returns a changeset, adding an error if "credit" and "debit" amounts
  are not equivalent
  """

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

  @doc """
  Accepts an `Fuentes.Entry` and `Ecto.Repo` and returns true/false based on whether
  the associated amounts for that entry sum to zero.
  """
  @spec balanced?(Ecto.Repo.t, Fuentes.Entry.t) :: Boolean.t
  def balanced?(repo \\ Config.repo, entry = %Entry{}) do
    credits = Amount |> Amount.for_entry(entry) |> Amount.sum_type("credit") |> repo.all
    debits = Amount |> Amount.for_entry(entry) |> Amount.sum_type("debit") |> repo.all

    if (debits - credits) == 0 do
      true
    else
      false
    end
  end
end
