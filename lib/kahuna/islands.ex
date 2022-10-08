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
           |> Enum.map(&Island.from_name/1)

  @type t :: [Island.t()]

  @spec new :: t()
  def new, do: @islands
end
