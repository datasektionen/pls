defmodule Pls.Repo.Membership do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:expiry]}
  schema "membership" do
    belongs_to :group, Pls.Repo.Group
    belongs_to :user, Pls.Repo.User
    
    field :expiry, :date
  end

  def new(uid, group_name, expiry) do
    user = Pls.Repo.one from(u in Pls.Repo.User, where: u.uid == ^uid)
    user = user || Pls.Queries.User.add_user uid
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group_name)
    group = group || Pls.Queries.Group.add_group group_name

    date = case Ecto.Date.cast expiry do
      {:ok, date} -> date
      :error -> raise "Invalid date"
    end

    %Pls.Repo.Membership{}
    |> cast(%{user_id: user.id, group_id: group.id, expiry: date}, [:user_id, :group_id, :expiry])
    |> unique_constraint(:membership, name: :membership_user_id_group_id_index)
  end
end

