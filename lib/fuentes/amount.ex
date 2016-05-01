# lib/fuentes/account.ex
defmodule Fuentes.Amount do

  schema "amounts" do
    field :type, :string
    field :amount, :decimal

    belongs_to :entry, Fuentes.Entry
    belongs_to :account, Fuentes.Amount

    timestamps
  end

  @fields ~w(type amount)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required([:description, :date])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> Ecto.Changeset.assoc_constraint([:entry, :account])
  end
end
