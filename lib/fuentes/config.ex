defmodule Fuentes.Config do
  @moduledoc """
  Stores configuration variables used to communicate with Fuentes

  Returns the Fuentes Tenancy Setting. Set it in `mix.exs`:

      config :fuentes, tenancy: :true
  """

  @doc """
    Selects the first repo from the list of configured `:ecto_repos` and establishes
    it as the default repo argument for those function which use a repo.
  """
  def repo, do: List.first(Application.get_env!(:fuentes, :ecto_repos))

  #def tenancy, do: Application.get_env(:fuentes, :tenancy)
end
