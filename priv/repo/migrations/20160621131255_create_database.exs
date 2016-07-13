defmodule Pls.Repo.Migrations.CreateDatabase do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :uid, :string, unique: true
    end
    create unique_index(:user, [:uid])

    create table(:group) do
      add :name, :string, unique: true
    end
    create unique_index(:group, [:name])

    create table(:membership) do
      add :user_id, references(:user, on_delete: :delete_all)
      add :group_id, references(:group, on_delete: :delete_all)
      add :expiry, :date
    end

    create table(:permission) do
      add :group_id, references(:group, on_delete: :delete_all)
      add :name, :string
    end
  end
end
