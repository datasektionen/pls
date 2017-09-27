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
    conn |> to_json(Pls.Queries.Group.group)
  end

  get "/:group" do
    conn |> to_json(Pls.Queries.Group.group group)
  end

  post "/:group" do
    conn |> to_json(Pls.Queries.Group.add_group URI.decode(group))
  end

  delete "/:group" do
    conn |> to_json(Pls.Queries.Group.delete_group group)
  end

  get "/:group/:permission" do
    conn |> to_json(Pls.Queries.Group.group group, permission)
  end

  post "/:group/:permission" do
    conn |> to_json(Pls.Queries.Group.add_permission URI.decode(group), URI.decode(permission))
  end

  delete "/:group/:permission" do
    conn |> to_json(Pls.Queries.Group.delete_permission group, permission)
  end

end
