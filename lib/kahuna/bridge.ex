defmodule Kahuna.Bridge do
  use TypedStruct
  alias Kahuna.Island
  alias Kahuna.Player

  @type id :: {Island.id(), Island.id()}

  typedstruct do
    field :id, id(), enforce: true
    field :owner, Player.id(), enforce: false
  end

  #####################################
  # CONSTRUCTORS
  #####################################

  @spec new(Island.t(), Island.t()) :: t()
  def new(from, to) do
    %__MODULE__{id: {from, to}}
  end

  #####################################
  # CONVERTERS
  #####################################

  def id(%__MODULE__{id: val}), do: val
  def owner(%__MODULE__{owner: val}), do: val
  def island_ids(%__MODULE__{id: {id1, id2}}), do: [id1, id2]

  @spec connected_to?(t(), Island.id()) :: boolean()
  def connected_to?(bridge, island_id) do
    connected? = island_id in island_ids(bridge)
    # IO.inspect({island_id, bridge, connected?})
    connected?
  end

  @spec other_island_id!(t(), Island.id()) :: Island.id()
  def other_island_id!(bridge, island_id) do
    bridge
    |> island_ids
    |> Enum.reject(&(&1 == island_id))
    |> case do
      [other_island_id] -> other_island_id
      _ -> raise "Expected #{inspect(bridge)} to be connected to #{inspect(island_id)}"
    end
  end

  #####################################
  # BOUNDARY
  #####################################

  @spec build(t(), Player.id()) :: {:ok, t()} | {:error, String.t()}
  def build(bridge, player_id) do
    case bridge.owner do
      nil ->
        new_bridge = set_owner(bridge, player_id)
        {:ok, new_bridge}

      ^player_id ->
        {:error, "Bridge is already build by Player #{player_id}"}

      _ ->
        {:error, "Bridge already exists here, owned by opponent"}
    end
  end

  @spec set_owner(t(), Player.id()) :: t()
  def set_owner(bridge, player_id) do
    struct!(bridge, owner: player_id)
  end

  #####################################
  # HELPERS
  #####################################

  @spec build_id(Island.id(), Island.id()) :: id()
  def build_id(island_id_1, island_id_2) do
    [island_id_1, island_id_2]
    |> Enum.sort()
    |> List.to_tuple()
  end
end
