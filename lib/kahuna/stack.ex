defmodule Kahuna.Stack do
  @moduledoc """
  A stack of cards needs a way of determining if it contains a card,
  sorting it to the top and popping it.
  """

  @type t :: Enum.t()
  @type find_fn :: (any -> boolean())

  @spec move_to_top([item], find_fn) :: {:ok, [item]} | :error when item: var
  def move_to_top(stack, find_fn) do
    do_move_to_top(stack, find_fn, [])
  end

  @spec do_move_to_top(
          remaining_items :: [item],
          find_fn(),
          searched_items_in_rev_order :: [item]
        ) :: {:ok, [item]} | :error
        when item: var
  defp do_move_to_top([], _find_fn, _all_items_in_rev_order) do
    :error
  end

  defp do_move_to_top([next_item | remaining_items], find_fn, searched_items) do
    if find_fn.(next_item) do
      new_stack = Enum.reduce(searched_items, remaining_items, &[&1 | &2])
      {:ok, [next_item | new_stack]}
    else
      do_move_to_top(remaining_items, find_fn, [next_item | searched_items])
    end
  end
end
