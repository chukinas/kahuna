defmodule Kahuna.StateMachineTest do
  use ExUnit.Case

  describe "The PlayCards phase" do
    test "is the first phase of a turn"
    test "is when PlaceBridge is done"
    test "is when RemoveBridge is done"
    test "ends automatically if cards in hand do not allow bridge to be placed"
    test "ends automatically if cards in hand do not allow bridge to be removed"
    test "can be ended manually with the EndCardPlay action"
  end

  describe "The EndTurn phase" do
    test "comes after the PlayCards phase"
    test ""
  end
end
