defmodule Pls.Repo.Migrations.RemoveUsers do
  use Ecto.Migration

  def change do
    alter table(:membership) do
      add :uid, :string
    end

    rename table(:user), to: table(:users)

    execute copy_uid_to_membership(), create_users_from_memberships()

    alter table(:membership) do
      remove :user_id
    end
    
    create index(:membership, [:uid])
  end

  def copy_uid_to_membership do
    "
    UPDATE membership
    SET uid = T2.uid
    FROM users AS T2
    WHERE user_id = T2.id;
    "
  end

  def create_users_from_memberships do
    "
    INSERT INTO users SELECT DISTINCT id, uid FROM membership;
    UPDATE membership
    SET user_id = T2.id
    FROM users as T2
    WHERE membership.uid = T2.uid;
    "
  end
end
