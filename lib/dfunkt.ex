defmodule Pls.Dfunkt do
  import HTTPotion

  def get_mandates uid do
    res = get("http://dfunkt.froyo.datasektionen.se/api/user/kthid/" <> uid <> "/current")

    json = case Poison.decode(res.body) do
      {:ok, json} -> json
      {:error, _} -> %{"mandates" => []}
    end

    json["mandates"] |> Enum.map(&(&1["Role"]["email"]))
  end
end
