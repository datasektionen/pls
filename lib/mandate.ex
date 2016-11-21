defmodule Pls.API.Mandate do
  use Maru.Router

  desc "/mandate/ prefix"
  namespace :mandate do
    route_param :mandate do
      desc "handles GET /:mandate"
      get do
        conn |> json(Pls.Queries.mandate_member params.mandate)
      end

      route_param :group do
        desc "handles GET /:mandate/:group"
        get do
          conn |> json(Pls.Queries.mandate_member params.mandate, params.group)
        end

        desc "handles POST /:mandate/:group"
        params do
          requires :mandate, type: String
          requires :group, type: String
        end
        post do
          conn |> json(Pls.Queries.add_mandate_member params.mandate, params.group)
        end

        desc "handles DELETE /:mandate/:group"
        delete do
          conn |> json(Pls.Queries.delete_mandate_member params.mandate, params.group)
        end
      end
    end
  end
end
