# lib/fuentes/account.ex
defmodule Fuentes.Amount do
  @moduledoc false

  @doc ~S"""
  The Amount class represents debit and credit amounts in the system.

  An amount must be a subclassed as either a debit or a credit to be saved to the database.

  """

  use Ecto.Schema
  import Ecto
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  schema "amounts" do
    field :type, :string
    field :amount, :decimal

    belongs_to :entry, Fuentes.Entry
    belongs_to :account, Fuentes.Amount

    timestamps
  end

  @fields ~w(type amount)

  @amount_types ["Debit", "Credit"]

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required([:description, :date])
    |> Ecto.Changeset.assoc_constraint([:entry, :account])
    |> validate_inclusion(:type, @amount_types)
    |> validate_number(:amount, greater_than_or_equal_to: 0)
  end
end
