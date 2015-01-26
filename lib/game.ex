defmodule GameInfo do
  defstruct id: -1,
            wind: :East,
            players: [], # for holding player names
            jong: 0, # 0 - 3
            curPlayerId: 0, # 0 - 3
            coveredTiles: [],
            openedTiles: []

end

defmodule Game do
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

  def who_to_move(game) do
    GenServer.call(game, :who_to_move)
  end

  def play(game) do
    GenServer.call(game, :play)
  end

  ## Server callbacks
  def init(_args) do
    {:ok, new_game_info}
  end

  def handle_call({:join, player}, _from, gInfo) do
    cond do
      length(gInfo.players) < 4 ->
        newInfo = %{gInfo | players: [player | gInfo.players]}
        {:reply, {:ok, length(newInfo.players)}, newInfo}
      true ->
        {:reply, :err_game_full, gInfo}
    end
  end

  def handle_call(:info, _from, gInfo) do
    {:reply, gInfo, gInfo}
  end

  def handle_call(:who_to_move, _from, gInfo) do
    {:reply, {gInfo.curPlayerId, gInfo.players |> Enum.at(gInfo.curPlayerId)}, gInfo}
  end

  def handle_call(:play, _from, gInfo) do
    nplayers = length(gInfo.players)
    cond do
      nplayers != 4 -> {:reply, :num_players_incorrect, gInfo}
      true -> {:reply, :ok, gInfo}
    end
  end

  defp new_game_info() do
    %GameInfo{id: -1,
              wind: :East, 
              coveredTiles: Tile.all |> Enum.shuffle}

  end
end
