defmodule Fuentes.TestFactory do
  use ExMachina.Ecto, repo: Fuentes.TestRepo

  alias Fuentes.{Account, Amount, Entry}

  def account_factory do
    %Fuentes.Account{
      name: "My Assets",
      type: "Asset",
      contra: false
    }
  end
end
