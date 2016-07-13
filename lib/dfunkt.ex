defmodule Pls.Dfunkt do
  import HTTPotion

  def list_subset(list1, list2) do
    MapSet.subset? MapSet.new(list1), MapSet.new(list2)
  end

  def dfunkt_group?(uid) do
    url = "https://dfunkt.datasektionen.se/people/" <> uid
    res = get(url, headers: ["Accept": "application/json"])

    json = case Poison.decode(res.body) do
      {:ok, json} -> json
      {:error, _} -> raise Maru.Exceptions.NotFound
    end

    current_offices = json["current_offices"]

    drek_offices = [
      "Ledamot för sociala frågor och relationer",
      "Ledamot för studiemiljöfrågor",
      "Ledamot för utbildningsfrågor",
      "Kassör",
      "Sektionsordförande",
      "Sekreterare",
      "Vice sektionsordförande"
    ]

    cond do
      list_subset current_offices, drek_offices -> "drek"
      length(current_offices) > 0               -> "dfunkt"
      true                                      -> "user"
    end
  end
end
