# lib/fuentes/account.ex
defmodule Fuentes.Account do

  schema "accounts" do
    field :name, :string
    field :type, :string
    field :contra, :boolean, default: false

    timestamps
  end

  @fields ~w(name type contra)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
    |> validate_required([:name, :type])
  end
end
