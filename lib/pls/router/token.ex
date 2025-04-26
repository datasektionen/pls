defmodule Pls.Router.Token do
  use Plug.Router
  plug :match
  plug :dispatch

  import Pls.Router.Helpers

  get "/:token" do
    conn |> send_api_result(Pls.Queries.Token.get_token(token))
  end

  get "/:token/:system" do
    conn |> send_api_result(Pls.Queries.Token.get_token(token, system))
  end

  get "/:token/:system/:permission" do
    conn |> send_api_result(Pls.Queries.Token.get_token(token, system, permission))
  end

  post "/:tag/:group" do
    conn |> send_api_result(Pls.Queries.Token.add_token(URI.decode(tag), URI.decode(group)))
  end

  delete "/:tag/:group" do
    conn |> send_api_result(Pls.Queries.Token.delete_token(tag, group))
  end

  match _ do
    conn |> send_resp(404, "Not found, or invalid token name")
  end
end
