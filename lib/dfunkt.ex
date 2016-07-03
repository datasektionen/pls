defmodule Pls.Dfunkt do
  import HTTPotion

  def is_elected?(uid) do
    url = "https://dfunkt.datasektionen.se/people/" <> uid
    res = get(url, headers: ["Accept": "application/json"])

    json = case Poison.decode(res.body) do
      {:ok, json} -> json
      {:error, _} -> raise Maru.Exceptions.NotFound
    end

    length(json["current_offices"]) > 0
  end
end
