defmodule Pls.Router.User do
  use Plug.Router
  plug :match
  plug :dispatch

  def to_json(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(data))
  end

  get "/:uid" do
    conn |> to_json(Pls.Queries.User.user uid)
  end

  get "/:uid/:system" do
    conn |> to_json(Pls.Queries.User.user uid, system)
  end

  get "/:uid/:system/:permission" do
    conn |> to_json(Pls.Queries.User.user uid, system, permission)
  end

  post "/:uid/:group" do
    case Ecto.Date.cast Map.get(conn.params, "expiry") do
      {:ok, expiry} ->
        conn |> to_json(Pls.Queries.User.add_membership(uid, URI.decode(group), expiry))
      :error ->
        conn |> send_resp(400, "Missing or invalid expiry")  
    end
  end

  delete "/:uid/:group" do
    conn |> to_json(Pls.Queries.User.delete_membership uid, group)
  end

  get _ do
    conn |> send_resp(404, "Not found")
  end

end
