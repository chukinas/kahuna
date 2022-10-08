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

  @spec id(t()) :: id()
  def id(%__MODULE__{id: id}), do: id

  #####################################
  # BOUNDARY
  #####################################

  @spec build(t(), Player.id()) :: {:ok, t()} | {:error, String.t()}
  def build(bridge, player_id) do
    case bridge.owner do
      nil ->
        new_bridge = struct!(bridge, owner: player_id)
        {:ok, new_bridge}

      ^player_id ->
        {:error, "Bridge is already build by Player #{player_id}"}

      _ ->
        {:error, "Bridge already exists here, owned by opponent"}
    end
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
