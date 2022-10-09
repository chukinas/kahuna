defmodule Kahuna.Player do
  @type id :: 1..2
  @type maybe_id :: nil | id()

  @spec ids :: [id()]
  def ids, do: [1, 2]
end
