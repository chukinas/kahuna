defprotocol Kahuna.PlayerAction do
  alias Kahuna.Game

  @spec execute(t(), Game.t()) :: {:ok, Game.t()} | {:error, String.t()}
  def execute(action, game)
end
