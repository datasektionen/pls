defmodule Pls.Repo.Membership do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:uid, :expiry]}
  schema "membership" do
    belongs_to :group, Pls.Repo.Group
    # belongs_to :user, Pls.Repo.User

    field :uid, :string
    field :expiry, :date
  end

  def new(uid, group_name, expiry) do
    group = Pls.Repo.one(from(g in Pls.Repo.Group, where: g.name == ^group_name))
    group = group || Pls.Queries.Group.add_group(group_name)


    Ecto.build_assoc(group, :memberships)
    |> cast(%{uid: uid, expiry: expiry}, [:uid, :expiry])
    |> unique_constraint(:membership, name: :membership_uid_group_id_index)
  end
end
