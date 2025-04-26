defmodule Pls.Router.Mandate do
  use Plug.Router
  plug :match
  plug :dispatch

  import Pls.Router.Helpers

  get "/:mandate" do
    conn |> send_api_result(Pls.Queries.Mandate.mandate(mandate))
  end

  get "/:mandate/:group" do
    conn |> send_api_result(Pls.Queries.Mandate.mandate(mandate, group))
  end

  post "/:mandate/:group" do
    conn
    |> send_api_result(Pls.Queries.Mandate.add_mandate(URI.decode(mandate), URI.decode(group)))
  end

  delete "/:mandate/:group" do
    conn |> send_api_result(Pls.Queries.Mandate.delete_mandate(mandate, group))
  end

  match _ do
    conn |> send_resp(404, "Not found, or invalid mandate name")
  end
end
