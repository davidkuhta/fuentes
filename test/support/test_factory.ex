defmodule Fuentes.TestFactory do
  use ExMachina.Ecto, repo: Fuentes.TestRepo

  alias Fuentes.{Account, Amount, Entry}

  def account_factory do
    %Fuentes.Account{
      name: "My Assets",
      type: "asset",
      contra: false
    }
  end

  def entry_factory do
    %Fuentes.Entry{
      description: "Investing in Koenigsegg",
      date: %Ecto.Date{ year: 2016, month: 5, day: 16 },
      amounts: [ build(:credit), build(:debit) ]
    }
  end

  def credit_factory do
    %Fuentes.Amount{
      amount: Decimal.new(125000.00),
      type: "credit",
      account_id: 1
    }
  end

  def debit_factory do
    %Fuentes.Amount{
      amount: Decimal.new(125000.00),
      type: "debit",
      account_id: 2
    }
  end
end
