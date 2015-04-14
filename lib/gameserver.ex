require Logger
defmodule GameServer do
  use GenServer

  ## Client API
  def start_link() do
    GenServer.start_link(__MODULE__, [], [])
  end

  def join(game, player) do
    GenServer.call(game, {:join, player})
  end

  def info(game) do
    GenServer.call(game, :info)
  end

  @doc """
  Return all possible moves
  """
  def moves(game) do
    GenServer.call(game, :moves)
  end

  @doc """
  Send all actions from user for this round
  Game server will select the highest priority action and update game state using that action
  """
  def act(game, action_list) do
    GenServer.call(game, {:act, action_list})
  end

  ## Server callbacks
  def init(_args) do
    {:ok, Game.new}
  end

  def handle_call({:join, player}, _from, gInfo) do
    cond do
      length(gInfo.players) < 4 ->
        newInfo = %{gInfo | players: [player | gInfo.players]}
        {:reply, {:ok, length(newInfo.players) - 1}, newInfo} # returning {:ok, pid} to client
      true ->
        {:reply, :err_game_full, gInfo}
    end
  end

  def handle_call(:info, _from, gInfo) do
    {:reply, gInfo, gInfo}
  end

  def handle_call(:moves, _from, gInfo) do
    {:reply, gInfo.possiblePlayerMoves, gInfo}
  end

  ## short cut for passing only a single action ** Mainly for testing **
  def handle_call({:act, {pid, action, pattern}}, from, gInfo) do
    handle_call({:act, [{pid, action, pattern}]}, from, gInfo)
  end

  ## action_list should be a list of tuple {player_id, :pung|:sheung|:gong|:win|:draw, pattern} **same tuple as the one return by :moves call
  def handle_call({:act, action_list}, _from, gInfo) do
    ## update the possible action to be the selected player to discard a tile
    gInfo1 = Game.action(gInfo, action_list)
    {:reply, :ok, gInfo1}
  end

end
