defmodule Fuentes.TestRepo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :contra, :boolean, default: false

      timestamps
    end

    create index(:accounts, [:name, :type])
  end
end
