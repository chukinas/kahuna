defmodule Kahuna.Island do
  use TypedStruct

  @type id :: :a | :b | :c | :d | :e | :f | :g | :h | :i | :j | :k | :l

  typedstruct do
    field :id, non_neg_integer()
    field :name, String.t()
  end

  @spec new(non_neg_integer(), String.t()) :: t()
  def new(id, name) when is_integer(id) and is_binary(name) do
    %__MODULE__{id: id, name: name}
  end
end
