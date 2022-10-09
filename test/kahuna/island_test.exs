defmodule Kahuna.IslandTest do
  use ExUnit.Case
  alias Kahuna.Bridge
  alias Kahuna.Bridges
  alias Kahuna.Island
  alias Kahuna.Islands

  # setup do
  #   associated_bridge_ids = fn island_id ->
  #     island_id
  #     |> Bridges.connected_to_island()
  #     |> Enum.map(&Bridge.id/1)
  #   end

  #   bridge_ids_grouped_by_island_id =
  #     Islands.ids()
  #     |> Enum.map(&{&1, associated_bridge_ids.(&1)})
  #     |> Map.new()

  #   [bridge_ids_by_island: bridge_ids_grouped_by_island_id]
  # end

  # setup %{bridge_ids_by_island: bridges} do
  #   odd_bridge_count? = fn island_id ->
  #     1 == Enum.mod(bridges[island_id], 2)
  #   end

  #   shuffled_island_ids = Islands.ids() |> Enum.shuffle()
  # end

  # setup do
  #   game = Game.new()
  #   [game: game]
  # end

  test "Island.connections_count/1 returns 3 for Aloa island" do
    aloa = Islands.fetch_by_id!(:a)
    assert Island.connections_count(aloa) == 3
  end

  describe "Island.should_owner/2" do
    cases = [
      {"Aloa", :a, 3, 1, nil},
      {"Aloa", :a, 3, 2, 1},
      {"Aloa", :a, 3, 3, 1},
      {"Duda", :d, 4, 1, nil},
      {"Duda", :d, 4, 2, nil},
      {"Duda", :d, 4, 3, 1},
      {"Duda", :d, 4, 4, 1}
    ]

    for {island_name, island_id, total_bridge_count, owned_bridge_count, return_val} <-
          cases do
      test "returns #{inspect(return_val)} if island has #{inspect(total_bridge_count)} bridges and player owns #{inspect(owned_bridge_count)}" do
        player_id = 1
        island_id = unquote(island_id)
        owned_bridge_count = unquote(owned_bridge_count)
        island = island_by_id(island_id)
        bridges = bridges(player_id, island_id, owned_bridge_count)
        assert Island.name(island) == unquote(island_name)
        assert Island.id(island) == island_id
        assert Island.connections_count(island) == unquote(total_bridge_count)
        assert Island.should_owner(island, bridges) == unquote(return_val)
      end
    end
  end

  defp island_by_id(island_id) do
    %Island{} = Islands.new() |> Enum.find(&(Island.id(&1) == island_id))
  end

  defp bridges(player_id, island_id, bridge_count) do
    connected_bridges = Bridges.by_island_id(island_id)

    if bridge_count > length(connected_bridges) do
      raise "bridge_count cannout be larger than number of connected islands"
    end

    bridge_ids =
      connected_bridges
      |> Enum.shuffle()
      |> Stream.map(&Bridge.id/1)
      |> Enum.take(bridge_count)

    set_owner = &Bridge.set_owner(&1, player_id)
    bridge_in_list? = fn bridge -> Bridge.id(bridge) in bridge_ids end
    Bridges.new() |> Bridges.update_all(set_owner, bridge_in_list?)
  end
end
