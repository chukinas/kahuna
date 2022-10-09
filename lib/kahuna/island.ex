defmodule Kahuna.Island do
  use TypedStruct
  alias Kahuna.Player
  alias Kahuna.Bridge
  alias Kahuna.Bridges

  @type id :: :a | :b | :c | :d | :e | :f | :g | :h | :i | :j | :k | :l

  typedstruct enforce: true do
    field :id, id()
    field :name, String.t()
    field :owner, Player.id(), enforce: false
  end

  #####################################
  # CONSTRUCTORS
  #####################################

  def from_name(name) do
    id = name |> String.first() |> String.downcase() |> String.to_atom()
    %__MODULE__{id: id, name: name}
  end

  #####################################
  # REDUCERS
  #####################################

  @spec set_owner(t(), Player.id()) :: t()
  def set_owner(island, owner), do: struct!(island, owner: owner)

  @spec should_owner(t(), Bridges.t()) :: Player.maybe_id()
  def should_owner(island, bridges) do
    min_bridge_count_for_ownership = ownership_bridge_count(island)

    bridges
    |> Bridges.by_island_id(island.id)
    |> Enum.frequencies_by(&Bridge.owner/1)
    |> Map.take(Player.ids())
    |> Enum.filter(fn {_player_id, bridge_count} ->
      bridge_count >= min_bridge_count_for_ownership
    end)
    |> case do
      [{player_id, _bridge_count}] -> player_id
      [] -> nil
    end
  end

  #####################################
  # CONVERTERS
  #####################################

  def id(%__MODULE__{id: val}), do: val
  def owner(%__MODULE__{owner: val}), do: val
  def name(%__MODULE__{name: val}), do: val

  @spec connections_count(t()) :: pos_integer()
  def connections_count(%__MODULE__{id: id}) do
    id
    |> Bridges.by_island_id()
    |> Enum.count()
  end

  # A player owns an island if they have build MORE THAN HALF the available bridges.
  @spec ownership_bridge_count(t()) :: pos_integer()
  defp ownership_bridge_count(island) do
    island
    |> connections_count
    |> Integer.floor_div(2)
    |> Kernel.+(1)
  end

  @spec owner?(t(), Player.id()) :: boolean()
  def owner?(island, player_id), do: island.owner == player_id

  @spec update_control(t(), Bridges.t()) :: {:change | :no_change, t()}
  def update_control(island, bridges) do
    {previous_owner, updated_island} = get_and_update_control(island, bridges)

    case owner(updated_island) do
      ^previous_owner -> {:no_change, updated_island}
      _ -> {:change, updated_island}
    end
  end

  @spec get_and_update_control(t(), Bridges.t()) :: {Player.maybe_id(), t()}
  defp get_and_update_control(island, bridges) do
    current_owner = owner(island)

    island =
      case should_owner(island, bridges) do
        ^current_owner -> island
        should_owner -> set_owner(island, should_owner)
      end

    {current_owner, island}
  end
end
