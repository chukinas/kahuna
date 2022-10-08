defmodule Kahuna.Islands do
  alias Kahuna.Island

  @islands ~w/
           Aloha
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
           |> Stream.with_index(1)
           |> Enum.map(fn {name, id} -> Island.new(id, name) end)

  @type t :: [Island.t()]

  @spec new :: t()
  def new, do: @islands
end
