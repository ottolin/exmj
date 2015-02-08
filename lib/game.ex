defmodule GameInfo do
  defstruct id: -1,
            wind: :East,
            players: [], # for holding player names
            jong: 0, # 0 - 3
            lastPlayerId: 3, # 0 - 3
            possiblePlayerMoves: [],
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

  def moves(game) do
    GenServer.call(game, :moves)
  end

  def player_action(game, {:act, pid, action}) do
  end

  ## Server callbacks
  def init(_args) do
    {:ok, new_game_info}
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

  def handle_call({:act, pid, action}, _from, gInfo) do
  end

  ## Helper functions

  defp check_sheung(_pid, _hand, :invalid) do
    []
  end

  ## we need to ensure the pid is ok to sheung before calling this function
  defp check_sheung(pid, {hand_tiles, _fixed_tiles}, last_played_tile) do
    Tile.find_3([last_played_tile | hand_tiles])
    |> Enum.reduce([], fn pattern, acc -> 
                          cond do
                            (last_played_tile in pattern) && Tile.sheung(pattern) -> [{pid, :sheung, pattern} | acc]
                            true -> acc
                          end
                        end)
  end

  defp check_gong(pid, {hand_tiles, fixed_tiles}, :invalid) when rem(length(hand_tiles), 3) == 2 do
    # here we need to check if the player can gong by his own tiles

    # 4 dark gong
    # 1. group all the same tiles to the same list
    # 2. only select those with length of 4
    four_dark_gong = hand_tiles 
    |> Enum.group_by(fn t -> t end)
    |> Map.values
    |> Enum.reduce([], fn grouped_tiles, acc -> 
                          case length(grouped_tiles) do
                            4 -> # ok, we can do a dark gong
                                [{pid, :gong, (for _ <- 1..4, do: hd(grouped_tiles))} | acc]
                            _else -> acc
                          end
                       end)

    # 1 dark gong
    # 1. in fixed_tiles, find all 'pung' patterns and make sure the tile in the patterns is also in our current hand_tile
    one_dark_gong = fixed_tiles
    |> Enum.reduce([], fn pattern, acc -> 
                          cond do
                            Tile.pung(pattern) && (hd(pattern) in hand_tiles) -> [{pid, :gong, hd(pattern)} | acc]
                            true -> acc
                          end
                        end )

    four_dark_gong ++ one_dark_gong
  end

  defp check_gong(_pid, _hand, :invalid) do
    []
  end

  defp check_gong(pid, {hand_tiles, _fixed_tiles}, last_played_tile) when rem(length(hand_tiles) + 1, 3) == 2 do
    # 1. in hand_tiles, make sure we have 3 of the kind same as last_played_tile
    same_on_hand = hand_tiles
    |> Enum.count(fn ht -> Tile.same(last_played_tile, ht) end)

    can_gong = (same_on_hand == 3)
    cond do
      can_gong -> [{pid, :gong, (for _ <- 1..4, do: last_played_tile)}]
      true -> []
    end
  end

  defp check_pung(_pid, _hand, :invalid) do
    []
  end

  defp check_pung(pid, {hand_tiles, _fixed_tiles}, last_played_tile) do
    same_on_hand = hand_tiles
    |> Enum.count(fn ht -> Tile.same(last_played_tile, ht) end)

    can_pung = (same_on_hand >= 2)
    cond do
      can_pung -> [{pid, :pung, (for _ <- 1..3, do: last_played_tile)}]
      true -> []
    end
  end

  ## return a list of {player id, possible action, action pattern} , except for :win
  defp check_win(pid, hand, last_played_tile) do
    rv = do_check_win(pid, hand, last_played_tile)
    case rv do
      :not_win -> []
      {:win, fans} -> [{pid, :win, fans}]
    end
  end

  defp do_check_win(pid, {hand_tiles, fixed_tiles}, :invalid) do
    GameRule.win?(hand_tiles, fixed_tiles)
  end

  defp do_check_win(pid, {hand_tiles, fixed_tiles}, last_played_tile) do
    GameRule.win?([last_played_tile | hand_tiles], fixed_tiles)
  end

  defp wu do
    [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 2},
      #%Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 4},
      %Tile{cat: :dot, sub: :dot, num: 5},
      %Tile{cat: :dot, sub: :dot, num: 6},
      %Tile{cat: :bamboo, sub: :bamboo, num: 1},
      %Tile{cat: :bamboo, sub: :bamboo, num: 1}
    ]
  end

  defp get_possible_moves(gInfo) do
    po = play_order(gInfo.lastPlayerId)
    win = po |> Enum.flat_map(fn pid -> check_win(pid, hand_of(pid, gInfo), gInfo.lastPlayedTile) end )
    pung = po |> Enum.flat_map(fn pid -> check_pung(pid, hand_of(pid, gInfo), gInfo.lastPlayedTile) end )
    gong = po |> Enum.flat_map(fn pid -> check_gong(pid, hand_of(pid, gInfo), gInfo.lastPlayedTile) end )
    sheung = check_sheung(hd(po), hand_of(hd(po), gInfo), gInfo.lastPlayedTile)

    win ++ pung ++ gong ++ sheung ++ [{hd(po), :draw, []}]
  end

  defp play_order(last_player_id) do
    last_player_id + 1 .. last_player_id + 4
    |> Enum.map(&(rem(&1, 4)))
  end

  defp hand_of(pid, gInfo) do
    elem(gInfo.hands, pid)
  end

  defp new_game_info() do
    jong = 0
    {hands, coveredTiles} = dispatch_tiles(jong)
    gInfo = %GameInfo{
              id: -1,
              wind: :East, 
              jong: jong,
              coveredTiles: coveredTiles,
              #hands: Tuple.delete_at(Tuple.insert_at(hands, 0, {wu, []}), 1),
              hands: hands,
              #lastPlayedTile: %Tile{cat: :dot, sub: :dot, num: 3},
             }

    %{gInfo | possiblePlayerMoves: get_possible_moves(gInfo)}
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
