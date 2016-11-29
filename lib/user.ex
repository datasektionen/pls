defmodule Pls.API.User do
  use Maru.Router

  desc "/user/ prefix"
  namespace :user do
    desc "handles GET /"
    get do
      conn |> json(Pls.Queries.User.user)
    end

    route_param :uid do
      desc "handles GET /:uid"
      get do
        conn |> json(Pls.Queries.User.user params.uid)
      end

      route_param :group do
        desc "handles GET /:uid/:group"
        get do
          conn |> json(Pls.Queries.User.user params.uid, params.group)
        end

        desc "handles POST /:uid/:group"
        params do
          requires :uid, type: String
          requires :group, type: String
          requires :expiry, type: String, regexp: ~r/^\d{4}-\d{2}-\d{2}$/
        end
        post do
          conn |> json(Pls.Queries.User.add_membership params.uid, params.group, params.expiry)
        end

        desc "handles DELETE /:uid/:group"
        delete do
          conn |> json(Pls.Queries.User.delete_membership params.uid, params.group)
        end

        route_param :permission do
          desc "handles GET /:uid/:group/:permission"

          get do
            conn |> json(Pls.Queries.User.user params.uid, params.group, params.permission)
          end
        end
      end
    end
  end
end

defmodule Pls.Queries.User do
  import Ecto.Query

  def user do
    Pls.Repo.all from(u in Pls.Repo.User, select: u.uid)
  end

  def user(uid) do
    mandates = Pls.Dfunkt.get_mandates uid
    mandate_groups = from(m in Pls.Repo.MandateMember,
      where: m.name in ^mandates,
      preload: [group: :permissions])
    |> Pls.Repo.all
    |> Enum.map(&(&1.group))
    |> Enum.map(&(%{&1 | name: &1.name |> String.split(".") |> Enum.drop(-1) |> Enum.join(".")})) # remove .xxx suffix from name

    from(u in Pls.Repo.User,
      where: u.uid == ^uid,
      preload: [groups: :permissions])
    |> Pls.Repo.all
    |> Enum.flat_map(&Map.get &1, :groups)
    |> Enum.concat(mandate_groups)
    |> Enum.map(fn(group) ->
        {group.name, Enum.map(group.permissions, &(&1.name))}
      end)
    |> Enum.reduce(%{}, fn({name, permissions}, map) ->
        Map.update map, name, permissions, &Enum.uniq(Enum.concat &1, permissions)
      end)
  end

  def user(uid, group_name) do
    Map.get user(uid), group_name, false
  end

  def user(uid, group_name, permission) do
    permissions = user(uid, group_name)
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
