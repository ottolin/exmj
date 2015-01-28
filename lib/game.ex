defmodule GameInfo do
  defstruct id: -1,
            wind: :East,
            players: [], # for holding player names
            jong: 0, # 0 - 3
            curPlayerId: 0, # 0 - 3
            curPlayerChoices: [],
            coveredTiles: [],
            openedTiles: [],
            hands: :invalid, # for holding different player tiles. { {[tiles], [fixed_tiles]} * 4 }
            lastPlayedTile: :invalid

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

  ## {:ok, {player id, player name}, [available moves]}
  def handle_call(:who_to_move, _from, gInfo) do
    {:reply, {:ok, {gInfo.curPlayerId, gInfo.players |> Enum.at(gInfo.curPlayerId)}, gInfo.curPlayerChoices}, gInfo}
  end

  ## tiles: the hand tiles we want to check
  ## extraTile: the one that is not in player's hand. Usually the last one discarded by previous player
  defp possible_moves({hand_tiles, fixed_tiles}, extraTile) do
  #TODO: other things
    [:Draw]
  end

  ## no extra tile need to be checked, i.e. we have already have enough tiles on hand
  defp possible_moves({hand_tiles, fixed_tiles}, :none) do
  #TODO: other things
    [:Discard]
  end

  defp new_game_info() do
    jong = 0
    curPlayerId = 0
    {hands, coveredTiles} = dispatch_tiles(jong)
    jongtiles = hands |> Enum.at(jong) # get the hand of jong player
    %GameInfo{
              id: -1,
              wind: :East, 
              jong: jong,
              coveredTiles: coveredTiles,
              hands: hands,
              curPlayerId: curPlayerId,
              curPlayerChoices: possible_moves(jongtiles, :none)
             }

  end

  ## { [{[hand_tiles], [fixed_tiles]} * 4], [remain covered tiles] }
  defp dispatch_tiles(jong) do
    game_tiles = Tile.all |> Enum.shuffle
    times = 4
    dispatch_tiles(jong, game_tiles, times, [])
  end

  defp dispatch_tiles(_jong, remain_tiles, 0, result) do
    {result |> List.to_tuple, remain_tiles}
  end

  defp dispatch_tiles(jong, tiles, times, result) do
    hand_tiles = cond do
      ## flowers?
      (times - 1) == jong -> tiles |> Enum.take(14)
      true -> tiles |> Enum.take(13)
    end
    dispatch_tiles(jong, (tiles -- hand_tiles), (times - 1), [{hand_tiles, []} | result])
  end
end