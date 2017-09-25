defmodule Pls.Queries.User do
  import Ecto.Query

  def user do
    Pls.Repo.all from(u in Pls.Repo.User, select: u.uid)
  end

  def user(uid) do
    mandates = Pls.Dfunkt.get_mandates uid
    mandate_groups = from(m in Pls.Repo.Mandate,
      where: m.name in ^mandates,
      preload: [group: :permissions])
    |> Pls.Repo.all

    user_id = Pls.Repo.one from(u in Pls.Repo.User, where: u.uid == ^uid, select: u.id)

    groups = case user_id do
      nil -> mandate_groups
      id  -> from(m in Pls.Repo.Membership,
                  where: m.user_id == ^id and m.expiry > ^Ecto.Date.utc,
                  preload: [group: :permissions])
              |> Pls.Repo.all
              |> Enum.concat(mandate_groups)
    end

    groups |> Enum.map(fn(x) ->
        {
          x.group.name |> String.split(".") |> List.first,
          x.group.permissions |> Enum.map(&(&1.name))
        }
      end)
    |> Enum.reduce(%{}, fn({name, permissions}, map) ->
        map |> Map.update(name, permissions, &Enum.uniq(Enum.concat &1, permissions))
      end)
  end

  def user(uid, system) do
    Map.get user(uid), system, []
  end

  def user(uid, system, permission) do
    permissions = user(uid, system)
    permissions && Enum.member? permissions, permission
  end

  def add_user(uid) do
    Pls.Queries.insert Pls.Repo.User.new(uid)
  end
  def delete_user(uid) do
    Pls.Queries.delete from(g in Pls.Repo.User,
      where: g.uid == ^uid)
  end

  def add_membership(uid, group_name, expiry) do
    Pls.Queries.insert Pls.Repo.Membership.new(uid, group_name, expiry)
  end

  def delete_membership(uid, group_name) do
    user = Pls.Repo.one from(u in Pls.Repo.User, where: u.uid == ^uid)
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group_name)

    Pls.Queries.delete from(m in Pls.Repo.Membership, where: [user_id:  ^user.id, group_id: ^group.id])
  end

  def clean do
    Pls.Queries.delete from(m in Pls.Repo.Membership, where: m.expiry < ^Ecto.Date.utc)
  end

end
