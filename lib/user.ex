defmodule Pls.API.User do
  use Maru.Router

  desc "/user/ prefix"
  namespace :user do
    desc "handles GET /"
    get do
      conn |> json(Pls.Queries.user)
    end

    route_param :uid do
      desc "handles GET /:uid"
      get do
        conn |> json(Pls.Queries.user params.uid)
      end

      route_param :group do
        desc "handles GET /:uid/:group"
        get do
          conn |> json(Pls.Queries.user params.uid, params.group)
        end

        desc "handles POST /:uid/:group"
        params do
          requires :uid, type: String
          requires :group, type: String
          requires :expiry, type: String, regexp: ~r/^\d{4}-\d{2}-\d{2}$/
        end
        post do
          conn |> json(Pls.Queries.add_membership params.uid, params.group, params.expiry)
        end

        desc "handles DELETE /:uid/:group"
        delete do
          conn |> json(Pls.Queries.delete_membership params.uid, params.group)
        end

        route_param :permission do
          desc "handles GET /:uid/:group/:permission"

          get do
            conn |> json(Pls.Queries.user params.uid, params.group, params.permission)
          end
        end
      end
    end
  end
end
