defmodule Kahuna.Bridges do
  alias Kahuna.Bridge

  @all %{
         a: ~w/b d h/a,
         b: ~w/c d e f/a,
         c: ~w/f g k/a,
         d: ~w/e h/a,
         e: ~w/f h i j/a,
         f: ~w/g j/a,
         g: ~w/j k/a,
         h: ~w/i l/a,
         i: ~w/j k l/a,
         j: ~w/k/a,
         k: ~w/l/a,
         l: ~w//a
       }
       |> Stream.flat_map(fn {from, to_list} -> Enum.map(to_list, &{from, &1}) end)
       |> Enum.map(fn {from, to} -> Bridge.new(from, to) end)

  @type t :: [Bridge.t()]

  @spec new :: t()
  def new, do: @all
end
