defmodule Kahuna.Cards do
  alias Kahuna.Card
  alias Kahuna.Island
  alias Kahuna.Islands
  alias Kahuna.Player
  use TypedStruct

  @all_cards (for island <- Islands.new(), card_number <- 1..2 do
                Card.new(island, card_number)
              end)

  @type stack :: [Card.t()]

  @type hands :: %{Player.id() => stack()}
  @type fn_update_cards :: (stack() -> stack())

  typedstruct do
    field :face_up, stack(), default: []
    field :draw_pile, stack(), default: Enum.shuffle(@all_cards)
    field :hands, hands(), default: %{1 => [], 2 => []}
    field :discard_pile, stack(), default: []
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
  #       {%Card{} = card, remaining} -> {card, remaining}
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

  @spec last_discard!(t()) :: Card.t()
  def last_discard!(cards) do
    case cards.discard_pile do
      [last_discard | _] ->
        last_discard

      discards ->
        raise "Expected a discard pile with at least one card, found: #{inspect(discards)}."
    end
  end

  #####################################
  # CONVERTERS
  #####################################

  @spec set_player_hand(t(), Player.id(), stack()) :: t()
  defp set_player_hand(cards, player_id, new_hand) do
    new_hands = Map.replace!(cards.hands, player_id, new_hand)
    struct!(cards, hands: new_hands)
  end

  #####################################
  # CONVERTERS (BOUNDARY)
  #####################################

  @spec discard(t(), Player.id(), Island.id()) :: {:ok, t()} | {:error, String.t()}
  def discard(cards, player_id, island_id) do
    player_hand = player_hand(cards, player_id)

    with {:ok, [card_to_discard | remaining_player_hand]} <-
           bring_card_to_top(player_hand, island_id) do
      new_discards = [card_to_discard | cards.discard_pile]

      new_cards =
        cards
        |> set_player_hand(player_id, remaining_player_hand)
        |> struct!(discard_pile: new_discards)

      {:ok, new_cards}
    else
      :error -> {:error, "Expected #{inspect player_hand} Player #{player_id} hand to contain #{inspect island_id}"}
    end
  end

  @spec player_hand(t(), Player.id()) :: stack()
  defp player_hand(cards, player_id) do
    Map.fetch!(cards.hands, player_id)
  end

  #####################################
  # HELPERS
  #####################################

  @spec add_card_fn(Card.t()) :: fn_update_cards()
  defp add_card_fn(new_card) do
    fn stack -> [new_card | stack] end
  end

  @spec bring_card_to_top(stack(), Island.id()) :: {:ok, stack()} | :error
  defp bring_card_to_top(stack, island_id) do
    find_fn = &Card.has_island_id(&1, island_id)
    Kahuna.Stack.move_to_top(stack, find_fn)
  end
end
