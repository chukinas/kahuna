defmodule Kahuna.IslandCards do
  alias Kahuna.Islands
  alias Kahuna.IslandCard
  alias Kahuna.IslandCard, as: Card
  alias Kahuna.Player
  use TypedStruct

  @all_cards (for island <- Islands.new(), card_number <- 1..2 do
                Card.new(island, card_number)
              end)

  @type cards :: [IslandCard.t()]
  @type hands :: %{Player.id() => cards()}
  @type fn_update_cards :: (cards() -> cards())

  typedstruct do
    field :face_up, cards(), default: []
    field :draw_pile, cards(), default: Enum.shuffle(@all_cards)
    field :hands, hands(), default: %{1 => [], 2 => []}
    field :discard_pile, cards(), default: []
  end

  #####################################
  # CONSTRUCTORS
  #####################################

  def new do
    %__MODULE__{}
    |> refill_face_up_cards()
    |> draw_three(1)
    |> draw_three(2)
  end

  #####################################
  # REDUCERS
  #####################################

  @spec refill_face_up_cards(t()) :: t()
  defp refill_face_up_cards(island_cards) do
    draw_count = 3 - length(island_cards.face_up)
    {drawn_cards, new_draw_pile} = Enum.split(island_cards.draw_pile, draw_count)
    new_face_up = drawn_cards ++ island_cards.face_up
    %__MODULE__{island_cards | draw_pile: new_draw_pile, face_up: new_face_up}
  end

  @doc "player takes a card from draw pile"
  @spec draw_random(t(), Player.id()) :: t()
  def draw_random(island_cards, player_id) do
    [new_card | remaining_cards] = island_cards.draw_pile

    %__MODULE__{island_cards | draw_pile: remaining_cards}
    |> update_player_hand(player_id, add_card_fn(new_card))
  end

  # defp draw_face_up(island_cards, player_id, face_up_card_index) when is_integer(face_up_card_index) do
  #   {drawn_card, remaining} =
  #     case List.pop_at(island_cards.face_up, face_up_card_index) do
  #       {%IslandCard{} = card, remaining} -> {card, remaining}
  #       _ -> raise "out of bounds index"
  #     end

  #   %__MODULE__{island_cards | face_up: remaining}
  #   |> update_player_hand(player_id, add_card_fn(drawn_card))
  # end

  defp draw_three(island_cards, player_id) do
    island_cards
    |> draw_random(player_id)
    |> draw_random(player_id)
    |> draw_random(player_id)
  end

  @spec update_player_hand(t(), Player.id(), fn_update_cards()) :: t()
  defp update_player_hand(%__MODULE__{hands: hands} = island_cards, player_id, update_fn) do
    %__MODULE__{island_cards | hands: Map.update!(hands, player_id, update_fn)}
  end

  #####################################
  # CONVERTERS
  #####################################

  # @spec player_hand(t(), Player.id()) :: cards()
  # defp player_hand(%__MODULE__{hands: hands}, player_id) do
  #   Map.fetch!(hands, player_id)
  # end

  #####################################
  # HELPERS
  #####################################

  @spec add_card_fn(IslandCard.t()) :: fn_update_cards()
  defp add_card_fn(new_card) do
    fn stack -> [new_card | stack] end
  end
end
