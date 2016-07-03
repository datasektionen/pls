defmodule Pls.Queries do
  import Ecto.Query

  def seed do
    add_user "andmarte"
    add_user "test"

    add_group "prometheus"
    add_permission "prometheus", ["post", "sticky", "edit", "delete"]
    add_group "prometheus.dfunkt"
    add_permission "prometheus.dfunkt", ["post", "edit_own", "delete_own"]

    add_group "tv"
    add_permission "tv", ["post", "edit", "delete"]
    add_group "tv.dfunkt"
    add_permission "tv.dfunkt", ["post_with_expiry", "edit_own", "delete_own"]

    add_group "pls"
    add_group "pls.tv"
    add_group "pls.prometheus"

    add_membership "andmarte", "pls", {2017, 06, 01}
    
    add_membership "andmarte", "prometheus", {2017, 06, 01}
    add_membership "andmarte", "tv", {2017, 06, 01}

    nil
  end

  def permissions_to_names(group) do
    Enum.map(group.permissions, &(&1.name))
  end

  def insert(change) do
    case Pls.Repo.insert change do
      {:ok, struct} -> struct
      {:error, change} -> Ecto.Changeset.traverse_errors change, fn {msg, _} -> msg end
    end
  end

  def delete(query) do
    case Pls.Repo.delete_all query do
      {res, nil} -> res
      {_, err}   -> err
    end
  end

  def user do
    Pls.Repo.all from(u in Pls.Repo.User, select: u.uid)
  end

  def user(uid) do
    collection_groups = case Pls.Dfunkt.is_elected? uid do
      false -> %{}
      true -> from(c in Pls.Repo.Collection, 
        where: c.name == "dfunkt", 
        preload: [group: :permissions]) 
        |> Pls.Repo.all 
        |> Enum.map(fn(x) -> x.group end)
    end

    from(u in Pls.Repo.User,
      where: u.uid == ^uid,
      preload: [groups: :permissions])
    |> Pls.Repo.one
    |> (&(if &1 == nil, do: %{}, else: &1)).() # If user isnt found, return an empty map
    |> Map.get(:groups, [])                    # If :groups doesnt exist, return and empty list
    |> Enum.concat(collection_groups)          # Add the default groups if elected
    |> Enum.reduce(%{}, fn(group, acc) ->      # make map from group to list of permissions
        Map.put(acc, group.name, group |> permissions_to_names)
      end)
  end

  def user(uid, group_name) do
    Map.get user(uid), group_name, false
  end

  def user(uid, group_name, permission) do
    case user(uid, group_name) do
      false -> false
      list -> Enum.member? list, permission
    end
  end

  def group do
    Pls.Repo.all from(g in Pls.Repo.Group, select: g.name)
  end

  def group(name) do
    from(g in Pls.Repo.Group,
      where: g.name == ^name,
      preload: :permissions)
    |> Pls.Repo.one
    |> (&(if &1 == nil, do: %{permissions: []}, else: &1)).()
    |> permissions_to_names
  end

  def group(name, permission) do
    Enum.member? group(name), permission
  end

  def add_user(uid) do
    insert Pls.Repo.User.new(uid)
  end
  def delete_user(uid) do
    delete from(g in Pls.Repo.User,
      where: g.uid == ^uid)
  end

  def add_group(name) do
    insert Pls.Repo.Group.new(name)
  end

  def delete_group(name) do
    delete from(g in Pls.Repo.Group,
      where: g.name == ^name)
  end

  def add_permission(group_name, permissions) when is_list(permissions) do
    Enum.map(permissions, fn(permission) -> add_permission(group_name, permission) end)
  end

  def add_permission(group_name, permission) do
    insert Pls.Repo.Permission.new(group_name, permission)
  end

  def delete_permission(group_name, permission) do
    group_id = Pls.Repo.one from(g in Pls.Repo.Group,
      where: g.name == ^group_name, select: g.id)

    delete from(p in Pls.Repo.Permission, 
      where: [group_id: ^group_id, name: ^permission])
  end

  def add_membership(uid, group_name, expiry) do
    insert Pls.Repo.Membership.new(uid, group_name, expiry)
  end

  def delete_membership(uid, group_name) do
    user = Pls.Repo.one from(u in Pls.Repo.User, where: u.uid == ^uid)
    user = user || add_user uid
    
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group_name)
    group = group || add_group group_name

    delete from(m in Pls.Repo.Membership, where: [user_id:  ^user.id, group_id: ^group.id])
  end

  def add_to_collection(collection, group_name) do
    insert Pls.Repo.Collection.new(collection, group_name)
  end

  def remove_from_collection(collection, group_name) do
    group = Pls.Repo.one from(g in Pls.Repo.Group, where: g.name == ^group_name, select: g.id)

    delete from(c in Pls.Repo.Collection, where: [name: ^collection, group_id: ^group])
  end

  def clean do
    delete from(m in Pls.Repo.Membership, where: m.expiry < ^Ecto.Date.utc)
  end

end
