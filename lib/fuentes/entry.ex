# lib/fuentes/account.ex
defmodule Fuentes.Entry do

  schema "entries" do
    field :description, :string
    field :date, Ecto.Date

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
  end
end
