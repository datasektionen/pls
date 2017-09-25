defmodule Pls.Repo.Migrations.Token do
  use Ecto.Migration

  def change do
    create unique_index(:permission, [:name, :group_id])

    rename table(:mandate_member), to: table(:mandate)
    create unique_index(:mandate, [:name, :group_id])

    create table(:token) do
      add :group_id, references(:group, on_delete: :delete_all)
      add :tag, :string
      add :token, :string
    end
    create unique_index(:token, [:tag, :group_id])

  end
end
