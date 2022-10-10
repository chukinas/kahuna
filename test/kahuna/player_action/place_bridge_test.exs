defmodule Kahuna.PlayerAction.PlaceBridgeTest do
  use ExUnit.Case
  alias Kahuna.Bridge
  alias Kahuna.Bridges
  alias Kahuna.Island
  alias Kahuna.Islands

  test "A bridge cannot be placed on an occupied path"
  test "Player must have in hand one of the islands he is building between"
  test "The bridge must be placed on a valid path"
  test "The bridge must be placed on a valid path"
  describe "Consequences of placing a bridge:" do
    test "If the player now owns over half the paths to an island, he takes control of the island"
    test "When taking control of an island, all enemy bridges to that island are removed"
    test "Removing opponent's bridges as a result of placing a token can cause opponent to lose token on affected islands"
  end
end
