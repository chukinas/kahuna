defmodule Kahuna.Game do
  use TypedStruct
  alias Kahuna.Bridges
  alias Kahuna.IslandCards
  alias Kahuna.IslandCards, as: Cards
  alias Kahuna.Islands
  alias Kahuna.Player
  alias Kahuna.PlayerAction, as: Action

  typedstruct enforce: true do
    field :bridges, Bridges.t(), default: Bridges.new()
    field :island_cards, IslandCards.t(), default: IslandCards.new()
    field :islands, Islands.t(), default: Islands.new()
    field :current_player, Player.id(), default: 1
    field :actions, [Action.t()], default: []
  end

  #####################################
  # CONSTRUCTORS
  #####################################

  @spec new :: t()
  def new, do: %__MODULE__{}

  #####################################
  # BOUNDARY
  #####################################

  # TODO this shouldn't be called by PlayerAction.
  # TODO extract into another protocol
  @spec validate_player_turn(t(), Player.id()) :: :ok | :error
  def validate_player_turn(game, player_id) do
    case game.current_player do
      ^player_id -> :ok
      _ -> :error
    end
  end

  #####################################
  # REDUCERS
  #####################################

  @spec set_bridges(t(), Bridges.t()) :: t()
  def set_bridges(game, bridges), do: struct!(game, bridges: bridges)

  @spec set_cards(t(), Cards.t()) :: t()
  def set_cards(game, cards), do: struct!(game, island_cards: cards)

  #####################################
  # CONVERTERS
  #####################################

  @spec bridges(t()) :: Bridges.t()
  def bridges(%{bridges: bridges}), do: bridges

  @spec current_player_id(t()) :: Player.id()
  def current_player_id(%{current_player: id}), do: id
end
