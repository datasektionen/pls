defmodule Pls.Router.Group do
  use Plug.Router
  plug :match
  plug :dispatch

  def to_json(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(data))
  end

  get "/" do
    conn |> to_json(Pls.Queries.Group.group())
  end

  get "/:group" do
    conn |> to_json(Pls.Queries.Group.group(group))
  end

  post "/:group" do
    conn |> to_json(Pls.Queries.Group.add_group(URI.decode(group)))
  end

  delete "/:group" do
    conn |> to_json(Pls.Queries.Group.delete_group(group))
  end

  get "/:group/:permission" do
    conn |> to_json(Pls.Queries.Group.group(group, permission))
  end

  post "/:group/:permission" do
    group = URI.decode(group)
    permission = URI.decode(permission)

    conn |> to_json(Pls.Queries.Group.add_permission(group, permission))
  end

  delete "/:group/:permission" do
    conn |> to_json(Pls.Queries.Group.delete_permission(group, permission))
  end

  match _ do
    send_resp(conn, 404, "Not found, or invalid group name")
  end
end
