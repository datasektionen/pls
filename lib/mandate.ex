defmodule Pls.API.Mandate do
  use Maru.Router

  desc "/mandate/ prefix"
  namespace :mandate do
    route_param :mandate do
      desc "handles GET /:mandate"
      get do
        conn |> json(Pls.Queries.Mandate.mandate_member params.mandate)
      end

      route_param :group do
        desc "handles GET /:mandate/:group"
        get do
          conn |> json(Pls.Queries.Mandate.mandate_member params.mandate, params.group)
        end

        desc "handles POST /:mandate/:group"
        params do
          requires :mandate, type: String
          requires :group, type: String
        end
        post do
          conn |> json(Pls.Queries.Mandate.add_mandate_member params.mandate, params.group)
        end

        desc "handles DELETE /:mandate/:group"
        delete do
          conn |> json(Pls.Queries.Mandate.delete_mandate_member params.mandate, params.group)
        end
      end
    end
  end
end

defmodule Pls.Queries.Mandate do
  import Ecto.Query

  def mandate_member(mandate) do
    from(m in Pls.Repo.MandateMember,
      where: m.name == ^mandate,
      preload: :group)
    |> Pls.Repo.all
    |> Enum.map(&(&1.group.name))
  end

  def mandate_member(mandate, group_name) do
    mandate_member(mandate) |> Enum.member?(group_name)
  end

  def add_mandate_member(mandate_member, group_name) do
    Pls.Queries.insert Pls.Repo.MandateMember.new(group_name, mandate_member)
  end

  def delete_mandate_member(mandate_member, group_name) do
    group_id = Pls.Repo.one from(g in Pls.Repo.Group,
      where: g.name == ^group_name, select: g.id)

    Pls.Queries.delete from(p in Pls.Repo.MandateMember,
      where: [group_id: ^group_id, name: ^mandate_member])
  end

end
