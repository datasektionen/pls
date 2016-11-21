defmodule Pls.Dfunkt do
  import HTTPotion

  def list_subset list1, list2 do
    !MapSet.disjoint? MapSet.new(list1), MapSet.new(list2)
  end

  def get_mandates uid do
    res = get("http://dfunkt.froyo.datasektionen.se/api/user/kthid/" <> uid <> "/current")

    json = case Poison.decode(res.body) do
      {:ok, json} -> json
      {:error, _} -> %{"mandates" => []}
    end

    json["mandates"] |> Enum.map(&(&1["Role"]["email"]))
  end
end
