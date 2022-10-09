defmodule Kahuna.Bridges do
  alias Kahuna.Bridge
  alias Kahuna.Island
  alias Kahuna.Player

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
       |> Stream.map(fn {from, to} -> Bridge.new(from, to) end)
       |> Stream.map(&{Bridge.id(&1), &1})
       |> Map.new()

  @type t :: %{Bridge.id() => Bridge.t()}

  #####################################
  # CONSTRUCTORS
  #####################################

  @spec new :: t()
  def new, do: @all

  #####################################
  # REDUCERS
  #####################################

  @spec update_all(t(), (Bridge.t() -> Bridge.t()), (Bridge.t() -> boolean())) :: t()
  def update_all(bridges, update_fn, update_if \\ fn _ -> true end) do
    update_each = fn {id, bridge} ->
      if update_if.(bridge) do
        {id, update_fn.(bridge)}
      else
        {id, bridge}
      end
    end

    bridges
    |> Enum.map(update_each)
    |> Map.new()
  end

  #####################################
  # CONVERTERS
  #####################################

  @spec by_island_id(t(), Island.id()) :: [Bridge.t()]
  def by_island_id(bridges \\ @all, island_id) do
    bridges
    |> Map.values()
    |> Enum.filter(&Bridge.connected_to?(&1, island_id))
  end

  #####################################
  # BOUNDARY
  #####################################

  @spec build(t(), Player.id(), Island.id(), Island.id()) :: {:ok, t()} | {:error, String.t()}
  def build(bridges, player_id, island_id_1, island_id_2) do
    bridge_id = Bridge.build_id(island_id_1, island_id_2)

    with {:ok, bridge} <- Map.fetch(bridges, bridge_id),
         {:ok, new_bridge} <- Bridge.build(bridge, player_id) do
      new_bridges = Map.replace!(bridges, bridge_id, new_bridge)
      {:ok, new_bridges}
    else
      :error -> {:error, "There is no <#{island_id_1}, #{island_id_2}> bridge"}
      error -> error
    end
  end
end
