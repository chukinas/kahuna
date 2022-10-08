defmodule Kahuna.Bridge do
  use TypedStruct
  alias Kahuna.Island
  alias Kahuna.Player

  @type id :: {Island.id(), Island.id()}

  typedstruct do
    field :id, id(), enforce: true
    field :owner, Player.id(), enforce: false
  end

  @spec new(Island.t(), Island.t()) :: t()
  def new(from, to) do
    %__MODULE__{id: {from, to}}
  end
end
