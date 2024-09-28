defmodule Pls.Router.Mandate do
  use Plug.Router
  plug :match
  plug :dispatch

  def to_json(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(data))
  end

  get "/:mandate" do
    conn |> to_json(Pls.Queries.Mandate.mandate(mandate))
  end

  get "/:mandate/:group" do
    conn |> to_json(Pls.Queries.Mandate.mandate(mandate, group))
  end

  post "/:mandate/:group" do
    conn |> to_json(Pls.Queries.Mandate.add_mandate(URI.decode(mandate), URI.decode(group)))
  end

  delete "/:mandate/:group" do
    conn |> to_json(Pls.Queries.Mandate.delete_mandate(mandate, group))
  end

  match _ do
    conn |> send_resp(404, "Not found, or invalid mandate name")
  end
end
