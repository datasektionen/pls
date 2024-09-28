defmodule Pls.Router.Token do
  use Plug.Router
  plug :match
  plug :dispatch

  def to_json(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(data))
  end

  get "/:token" do
    conn |> to_json(Pls.Queries.Token.get_token(token))
  end

  get "/:token/:system" do
    conn |> to_json(Pls.Queries.Token.get_token(token, system))
  end

  get "/:token/:system/:permission" do
    conn |> to_json(Pls.Queries.Token.get_token(token, system, permission))
  end

  post "/:tag/:group" do
    conn |> to_json(Pls.Queries.Token.add_token(URI.decode(tag), URI.decode(group)))
  end

  delete "/:tag/:group" do
    conn |> to_json(Pls.Queries.Token.delete_token(tag, group))
  end

  match _ do
    conn |> send_resp(404, "Not found, or invalid token name")
  end
end
