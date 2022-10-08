defmodule Kahuna.Game do
  use TypedStruct
  alias Kahuna.Bridges
  alias Kahuna.IslandCards
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

  @spec new :: t()
  def new, do: %__MODULE__{}
end
