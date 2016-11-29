defmodule Pls.API.Group do
  use Maru.Router

  desc "/group/ prefix"
  namespace :group do
    desc "handles GET /"
    get do
      conn |> json(Pls.Queries.Group.group)
    end

    route_param :group do
      desc "handles GET /:group"
      get do
        conn |> json(Pls.Queries.Group.group params.group)
      end
      
      desc "handles POST /:group"
      params do
        requires :group, type: String
      end
      post do
        conn |> json(Pls.Queries.Group.add_group(URI.decode_www_form(params.group)))
      end

      desc "handles DELETE /:group"
      delete do
        conn |> json(Pls.Queries.Group.delete_group params.group)
      end

      route_param :permission do
        desc "handles GET /:group/:permission"
        get do
          group = params.group
          permission = params.permission

          case Pls.Queries.Group.group(group, permission) do
            true -> conn |> json(true)
            false -> conn |> put_status(401) |> json(false)
          end
        end

        desc "handles POST /:group/:permission"
        params do
          requires :group, type: String
          requires :permission, type: String
        end
        post do
          conn |> json(Pls.Queries.Group.add_permission params.group, params.permission)
        end
  
        desc "handles DELETE /:group/:permission"
        delete do
          conn |> json(Pls.Queries.Group.delete_permission params.group, params.permission)
        end
      end

    end
  end
end

defmodule Pls.Queries.Group do
  import Ecto.Query

  def group do
    Pls.Repo.all from(g in Pls.Repo.Group, select: g.name)
  end

  def group(name) do
    group = from(g in Pls.Repo.Group,
      where: g.name == ^name,
      preload: [:permissions, :mandate_members, [memberships: :user]])
    |> Pls.Repo.one

    if group == nil, do: raise Maru.Exceptions.NotFound

    %{permissions: Enum.map(group.permissions, &(&1.name)),
      memberships: Enum.map(group.memberships, &(%{name: &1.user.uid, expiry: &1.expiry})),
      mandate_members: Enum.map(group.mandate_members, &(&1.name))}
  end

  def group(name, permission) do
    Enum.member? group(name), permission
  end

  def add_group(name) do
    Pls.Queries.insert Pls.Repo.Group.new(name)
  end

  def delete_group(name) do
    Pls.Queries.delete from(g in Pls.Repo.Group,
      where: g.name == ^name)
  end

  def add_permission(group_name, permissions) when is_list(permissions) do
    Enum.map(permissions, fn(permission) -> add_permission(group_name, permission) end)
  end

  def add_permission(group_name, permission) do
    Pls.Queries.insert Pls.Repo.Permission.new(group_name, permission)
  end

  def delete_permission(group_name, permission) do
    group_id = Pls.Repo.one from(g in Pls.Repo.Group,
      where: g.name == ^group_name, select: g.id)

    Pls.Queries.delete from(p in Pls.Repo.Permission,
      where: [group_id: ^group_id, name: ^permission])
  end

end
