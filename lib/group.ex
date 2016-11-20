defmodule Pls.API.Group do
  use Maru.Router

  desc "/group/ prefix"
  namespace :group do
    desc "handles GET /"
    get do
      conn |> json(Pls.Queries.group)
    end

    route_param :group do
      desc "handles GET /:group"
      get do
        conn |> json(Pls.Queries.group params.group)
      end
      
      desc "handles POST /:group"
      params do
        requires :group, type: String
      end
      post do
        conn |> json(Pls.Queries.add_group(URI.decode_www_form(params.group)))
      end

      desc "handles DELETE /:group"
      delete do
        conn |> json(Pls.Queries.delete_group params.group)
      end

      route_param :permission do
        desc "handles GET /:group/:permission"
        get do
          group = params.group
          permission = params.permission

          case Pls.Queries.group(group, permission) do
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
          conn |> json(Pls.Queries.add_permission params.group, params.permission)
        end
  
        desc "handles DELETE /:group/:permission"
        delete do
          conn |> json(Pls.Queries.delete_permission params.group, params.permission)
        end
      end

    end
  end
end
