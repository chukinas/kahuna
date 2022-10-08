defmodule KahunaTest do
  use ExUnit.Case
  doctest Kahuna

  test "greets the world" do
    assert Kahuna.hello() == :world
  end
end
