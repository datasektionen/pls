defmodule Pls.Router.User do
  use Plug.Router
  plug :match
  plug :dispatch

  import Pls.Router.Helpers

  get "/:uid" do
    conn |> send_api_result(Pls.Queries.User.user(uid))
  end

  get "/:uid/:system" do
    conn |> send_api_result(Pls.Queries.User.user(uid, system))
  end

  get "/:uid/:system/:permission" do
    conn |> send_api_result(Pls.Queries.User.user(uid, system, permission))
  end

  post "/:uid/:group" do
    case Date.from_iso8601(Map.get(conn.params, "expiry")) do
      {:ok, expiry} ->
        send_api_result(conn, Pls.Queries.User.add_membership(uid, URI.decode(group), expiry))

      {:error, _err} ->
        send_resp(conn, 400, "Missing or invalid expiry")
    end
  end

  delete "/:uid/:group" do
    send_api_result(conn, Pls.Queries.User.delete_membership(uid, group))
  end

  match _ do
    send_resp(conn, 404, "Not found, or invalid user name")
  end
end
