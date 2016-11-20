defmodule Pls.Dfunkt do
  import HTTPotion

  def list_subset list1, list2 do
    !MapSet.disjoint? MapSet.new(list1), MapSet.new(list2)
  end

  def get_offices uid do
    url = "https://dfunkt.datasektionen.se/people/" <> uid
    res = get(url, headers: ["Accept": "application/json"])

    json = case Poison.decode(res.body) do
      {:ok, json} -> json
      {:error, _} -> %{"current_offices" => []}
    end

    json["current_offices"]
  end

  def dfunkt_group uid do
    current_offices = get_offices uid
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
      length(current_offices) == 0              -> "user"
      list_subset current_offices, drek_offices -> "drek"
      true                                      -> "dfunkt"
    end
  end

  def is_admin? uid do
    current_offices = get_offices uid
    admin_offices = [
      "Systemansvarig",
      "Kommunikatör",
      "Sektionsordförande"
    ]

    list_subset current_offices, admin_offices
  end
end
