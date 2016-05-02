defmodule Fuentes.Repo.Migrations.SetupTables do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :contra, :boolean, default: false

      timestamps
    end
    create index(:accounts, [:name, :type])

    create table(:entries) do
      add :description, :string, null: false
      add :date, :date, null: false

      timestamps
    end
    create index(:entries, [:date])

    create table(:amounts) do
      add :type, :string, null: false
      add :amount, :decimal, precision: 20, scale: 10, null: false
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :entry_id, references(:entries, on_delete: :delete_all), null: false

      timestamps
    end
    create index(:amounts, [:type])
    create index(:amounts, [:account_id, :entry_id])
    create index(:amounts, [:entry_id, :account_id])

  end
end
