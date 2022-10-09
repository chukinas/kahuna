defmodule Kahuna.Islands do
  alias Kahuna.Island

  @islands ~w/
           Aloa
           Bari
           Coco
           Duda
           Elai
           Faaa
           Gola
           Huna
           Iffi
           Jojo
           Kanu
           Lale
           /
           |> Enum.map(&Island.from_name/1)

  @type t :: [Island.t()]

  @spec new :: t()
  def new, do: @islands

  @spec ids :: [Island.id()]
  def ids, do: Enum.map(new(), &Island.id/1)

  def fetch_by_id!(island_id) do
    case Enum.find(@islands, &(Island.id(&1) == island_id)) do
      nil -> raise "Expected to find an island with id #{inspect(island_id)}"
      %Island{} = island -> island
    end
  end
end
