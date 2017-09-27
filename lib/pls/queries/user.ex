defmodule Pls.Queries.User do
  import Ecto.Query

  def mandates_and_memberships(uid) do
    mandates = Pls.Dfunkt.get_mandates uid
    mandates = from(m in Pls.Repo.Mandate,
      where: m.name in ^mandates,
      select: m.group_id)
    |> Pls.Repo.all

    memberships = from(m in Pls.Repo.Membership,
      where: m.uid == ^uid and m.expiry > ^Ecto.Date.utc,
      select: m.group_id)
    |> Pls.Repo.all

    Enum.concat(mandates, memberships)
  end

  def user(uid) do
    tokens = from(t in Pls.Repo.Token,
      where: t.token == ^uid,
      select: t.group_id)
    |> Pls.Repo.all

    groups = case tokens do
      [] -> mandates_and_memberships(uid)
      g  -> g
    end

    from(g in Pls.Repo.Group,
      where: g.id in ^groups,
      preload: :permissions)
    |> Pls.Repo.all
    |> Enum.map(fn(group) ->
        {
          group.name |> String.split(".") |> List.first,
          group.permissions |> Enum.map(&(&1.name))
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

  def add_membership(uid, group_name, expiry) do
    Pls.Queries.insert Pls.Repo.Membership.new(uid, group_name, expiry)
  end

  def delete_membership(uid, group_name) do
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group_name)

    Pls.Queries.delete from(m in Pls.Repo.Membership, where: [uid:  ^uid, group_id: ^group.id])
  end

  def clean do
    Pls.Queries.delete from(m in Pls.Repo.Membership, where: m.expiry < ^Ecto.Date.utc)
  end

end
