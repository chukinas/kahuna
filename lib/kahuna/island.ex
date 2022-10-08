defmodule Kahuna.Island do
  use TypedStruct

  @type id :: :a | :b | :c | :d | :e | :f | :g | :h | :i | :j | :k | :l

  typedstruct enforce: true do
    field :id, id()
    field :name, String.t()
  end

  def from_name(name) do
    id = name |> String.first |> String.downcase |> String.to_atom
    %__MODULE__{id: id, name: name}
  end
end
