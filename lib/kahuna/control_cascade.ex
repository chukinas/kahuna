defmodule Kahuna.ControlCascade do
  @moduledoc """
  When a player places a bridge...
  1. Check to see if that players gains control of either or both of the connecting islands
  2. If control is gained, all opponent's bridges are removed from those islands
  3. This could cause the oppoenent to lose control of islands
  """

  use TypedStruct
  alias Kahuna.Bridge
  alias Kahuna.Bridges
  alias Kahuna.Island
  alias Kahuna.Islands
  alias Kahuna.Player

  @type message ::
          {:gain_control | :lose_control, Player.id(), Island.id()}
          | {:lose_bridge, Player.id(), Bridge.id()}

  typedstruct enforce: true do
    field :islands, Islands.t()
    field :bridges, Bridges.t()
    field :messages, [message()], default: []
  end

  @spec new(Islands.t(), Bridges.t()) :: t()
  def new(islands, bridges) do
    %__MODULE__{islands: islands, bridges: bridges}
    |> gain_control
    |> lose_bridges
    |> lose_control
  end

  @spec gain_control(t()) :: t()
  defp gain_control(%__MODULE__{islands: islands, bridges: bridges} = cascade) do
    %{change: updated_islands, no_change: unchanged_islands} =
      islands
      |> Stream.map(&Island.update_control(&1, bridges))
      |> Enum.group_by(fn {status, _} -> status end, fn {_, island} -> island end)

    case updated_islands do
      [] ->
        cascade

      newly_controlled_islands ->
        islands = newly_controlled_islands ++ unchanged_islands

        messages =
          Enum.map(newly_controlled_islands, fn island ->
            {:gain_control, Island.owner(island), Island.id(island)}
          end)

        struct!(cascade, islands: islands, messages: messages)
    end
  end

  @spec lose_bridges(t()) :: t()
  defp lose_bridges(cascade), do: cascade

  @spec lose_control(t()) :: t()
  defp lose_control(cascade), do: cascade
end
