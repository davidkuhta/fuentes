defmodule Fuentes.Config do
  @moduledoc """
  Stores configuration variables used to communicate with Fuentes
  """

  @doc """
  Returns the Fuentes Tenancy Setting. Set it in `mix.exs`:

      config :fuentes, tenancy: :true
  """
  #def tenancy, do: Application.get_env(:fuentes, :tenancy)
end
