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
    conn |> to_json(Pls.Queries.User.user(uid))
  end

  get "/:uid/:system" do
    conn |> to_json(Pls.Queries.User.user(uid, system))
  end

  get "/:uid/:system/:permission" do
    conn |> to_json(Pls.Queries.User.user(uid, system, permission))
  end

  post "/:uid/:group" do
    case Date.from_iso8601(Map.get(conn.params, "expiry")) do
      {:ok, expiry} ->
        to_json(conn, Pls.Queries.User.add_membership(uid, URI.decode(group), expiry))

      {:error, _err} ->
        send_resp(conn, 400, "Missing or invalid expiry")
    end
  end

  delete "/:uid/:group" do
    to_json(conn, Pls.Queries.User.delete_membership(uid, group))
  end

  match _ do
    send_resp(conn, 404, "Not found, or invalid user name")
  end
end
