defmodule Kahuna.PlayerAction.PlaceBridge do
  use TypedStruct
  alias Kahuna.Bridges
  alias Kahuna.Card
  alias Kahuna.Cards
  alias Kahuna.ControlCascade
  alias Kahuna.Game
  alias Kahuna.Island
  alias Kahuna.Player

  typedstruct enforce: true do
    field :player_id, Player.id()
    field :card_id, Card.id()
    field :destination_island_id, Island.id()
  end

  @spec new(Player.id(), Card.id(), Island.id()) :: t()
  def new(player_id, card_id, destination_island_id) do
    %__MODULE__{
      player_id: player_id,
      card_id: card_id,
      destination_island_id: destination_island_id
    }
  end

  @spec execute(t(), Game.t()) :: {:ok, Game.t()} | {:error, String.t()}
  def execute(%__MODULE__{player_id: player_id} = action, game) do
    with :ok <- Game.validate_player_turn(game, player_id),
         {:ok, new_cards} <- Cards.discard(game.island_cards, player_id, action.card_id),
         island_id_start = new_cards |> Cards.last_discard!() |> Card.island_id(),
         island_id_end = action.destination_island_id,
         bridges = Game.bridges(game),
         player_id = Game.current_player_id(game),
         {:ok, new_bridges} <- Bridges.build(bridges, player_id, island_id_start, island_id_end) do
      %ControlCascade{bridges: cascaded_bridges, islands: cascaded_islands} =
        ControlCascade.new(game.islands, new_bridges)

      new_game =
        game
        |> Game.set_bridges(cascaded_bridges)
        |> Game.set_cards(new_cards)
        |> Game.set_islands(cascaded_islands)

      {:ok, new_game}
    end
  end

  defimpl Kahuna.PlayerAction do
    def execute(place_bridge_action, game) do
      Kahuna.PlayerAction.PlaceBridge.execute(place_bridge_action, game)
    end
  end
end
