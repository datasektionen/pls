defmodule Pls.Router.Group do
  import Pls.Router.Helpers

  use Plug.Router
  plug :match
  plug :dispatch

  get "/" do
    conn |> send_api_result(Pls.Queries.Group.group())
  end

  get "/:group" do
    conn |> send_api_result(Pls.Queries.Group.group(group))
  end

  post "/:group" do
    conn |> send_api_result(Pls.Queries.Group.add_group(URI.decode(group)))
  end

  delete "/:group" do
    conn |> send_api_result(Pls.Queries.Group.delete_group(group))
  end

  get "/:group/:permission" do
    conn |> send_api_result(Pls.Queries.Group.group(group, permission))
  end

  post "/:group/:permission" do
    group = URI.decode(group)
    permission = URI.decode(permission)

    conn |> send_api_result(Pls.Queries.Group.add_permission(group, permission))
  end

  delete "/:group/:permission" do
    conn |> send_api_result(Pls.Queries.Group.delete_permission(group, permission))
  end

  match _ do
    send_resp(conn, 404, "Not found, or invalid group name")
  end
end
