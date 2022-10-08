defmodule Kahuna.IslandCard do
  alias Kahuna.Island
  use TypedStruct

  @typedoc "Each island has two cards in the deck"
  @type card_number :: 1..2

  @typedoc "An island id and card number uniquely identifies each game in the game"
  @type id :: {Island.id(), card_number()}

  typedstruct do
    field :island_id, Island.t()
    field :card_number, card_number()
  end

  #####################################
  # CONSTRUCTORS
  #####################################

  @spec new(Island.id(), card_number()) :: t()
  def new(island_id, card_number) do
    %__MODULE__{island_id: island_id, card_number: card_number}
  end

  #####################################
  # CONVERTERS
  #####################################

  @spec id(t()) :: id()
  def id(%__MODULE__{island_id: island_id, card_number: card_number}) do
    {island_id, card_number}
  end
end
