require Logger
defmodule GameInfo do
  defstruct id: -1,
            wind: :East,
            players: [], # for holding player names
            jong: 0, # 0 - 3
            lastPlayerId: 3, # 0 - 3
            possiblePlayerMoves: [],
            coveredTiles: [],
            groundTiles: [],
            hands: :invalid, # for holding different player tiles. { {[tiles], [fixed_tiles]} * 4 }
            lastPlayedTile: :invalid,
            actions: [] # a queue for holding all user actions, can used for checking gong + win

end

defmodule Game do

  def new() do
    jong = 0
    {hands, coveredTiles} = dispatch_tiles(jong)
    gInfo = %GameInfo{
              id: -1,
              wind: :East, 
              jong: jong,
              coveredTiles: coveredTiles,
              hands: hands,
             }

    %{gInfo | possiblePlayerMoves: get_possible_moves(gInfo)}
  end

  def next(gInfo) do
    #TODO: gen next game
    new
  end

  def action(gInfo, action_list) do
    ## find the highest priority action
    next_move = select_next_move(gInfo, action_list)
    gInfo1 = gInfo
    case next_move do
      nil -> Logger.error "Invalid moves called:"
             action_list |> Enum.each( fn {pid, action, _pattern} -> Logger.error "Invalid move from player: " <> to_string(pid) <> " performing: " <> to_string(action) end)
      {pid, action, pattern} -> Logger.info "Player " <> to_string(pid) <> " performed: " <> to_string(action)
                                gInfo1 = apply_next_move(gInfo, {pid, action, pattern})
                                gInfo1 = %{gInfo1| actions: [next_move | gInfo1.actions]}
    end
    gInfo1
  end

  ## the order of return list is indicating priority of moves
  def get_possible_moves(gInfo) do
    po = play_order(gInfo.lastPlayerId)
    win = po |> Enum.flat_map(fn pid -> check_win(pid, hand_of(pid, gInfo), gInfo.lastPlayedTile) end )
    pung = po |> Enum.flat_map(fn pid -> check_pung(pid, hand_of(pid, gInfo), gInfo.lastPlayedTile) end )
    gong = po |> Enum.flat_map(fn pid -> check_gong(pid, hand_of(pid, gInfo), gInfo.lastPlayedTile) end )
    sheung = check_sheung(hd(po), hand_of(hd(po), gInfo), gInfo.lastPlayedTile)

    rv = win ++ pung ++ gong ++ sheung
    curp = hd(po)
    {current_player_hand_tiles, _fixed_tiles} = hand_of(curp, gInfo)
    rv = rv ++ cond do
      # need discard, having 3n+2 pieces
      rem(length(current_player_hand_tiles), 3) == 2 ->
        current_player_hand_tiles |> Enum.map(&({curp, :discard, &1}))
      true -> [{hd(po), :draw, []}]
    end
    rv
  end

  defp apply_next_move(gInfo, {pid, :discard, tile}) do
    {hand_tiles, fixed_tiles} = hand_of(pid, gInfo)
    newhand = {hand_tiles -- [tile], fixed_tiles}
    IO.inspect newhand
    tmp = %{gInfo| lastPlayedTile: tile,
             lastPlayerId: pid,
             groundTiles: [tile | gInfo.groundTiles],
             hands: put_elem(gInfo.hands, pid, newhand)
    }
    %{tmp| possiblePlayerMoves: get_possible_moves(tmp)}
  end

  defp apply_next_move(gInfo, {pid, :draw, _pattern}) do
    {hand_tiles, fixed_tiles} = hand_of(pid, gInfo)
    [drawed_tile| remain] = gInfo.coveredTiles
    newhand = {[drawed_tile | hand_tiles], fixed_tiles}
    tmp = %{gInfo| lastPlayedTile: :invalid,
             coveredTiles: remain,
             hands: put_elem(gInfo.hands, pid, newhand)
    }
    %{tmp| possiblePlayerMoves: get_possible_moves(tmp)}
  end

  defp apply_next_move(gInfo, {_pid, :pung, _pattern} = act) do
    apply_pung_or_sheung(gInfo, act)
  end

  defp apply_next_move(gInfo, {_pid, :sheung, _pattern} = act) do
    apply_pung_or_sheung(gInfo, act)
  end

  defp apply_next_move(gInfo, {pid, :gong, pattern}) do
    {hand_tiles, fixed_tiles} = hand_of(pid, gInfo)
    tile = hd(pattern)
    newhand_tiles = hand_tiles |> Enum.filter(&(!Tile.same(&1, tile))) # All the target gong tiles on hand will be removed
    newfixed_tiles = fixed_tiles |> Enum.filter( fn fix_pattern -> !(tile in fix_pattern) end) # All the target gong tiles on fixed will be removed (self draw 1 more same tile to gong)
    newhand = {newhand_tiles, [pattern | newfixed_tiles]}

    tmp = %{gInfo| lastPlayedTile: :invalid,
                   hands: put_elem(gInfo.hands, pid, newhand)
    }
    %{tmp| possiblePlayerMoves: get_possible_moves(tmp)}
  end

  defp apply_pung_or_sheung(gInfo, {pid, _act, pattern}) do
    {hand_tiles, fixed_tiles} = hand_of(pid, gInfo)
    newhand_tiles = [gInfo.lastPlayedTile | hand_tiles] -- pattern
    newhand = {newhand_tiles, [pattern | fixed_tiles]}

    ## we will not call get_possible_moves here
    ## since gong/win is NOT allowed after sheung/pung
    ## the only thing can be done after sheung/pung is discard
    %{gInfo| lastPlayedTile: :invalid,
             hands: put_elem(gInfo.hands, pid, newhand),
             possiblePlayerMoves: newhand_tiles |>Enum.map(&({pid, :discard, &1}))
    }
  end

  defp select_next_move(gInfo, action_list) do
    gInfo.possiblePlayerMoves |> Enum.find( fn pm -> pm in action_list end )
  end

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
      {:win, win_pattern} -> Enum.map(win_pattern, fn x -> {pid, :win, x} end)
    end
  end

  defp do_check_win(_pid, {hand_tiles, fixed_tiles}, :invalid) do
    win?(hand_tiles, fixed_tiles)
  end

  defp do_check_win(_pid, {hand_tiles, fixed_tiles}, last_played_tile) do
    win?([last_played_tile | hand_tiles], fixed_tiles)
  end

  ## Actual win checking code
  defp win?(hand_tiles, fixed_tiles \\ []) do
    wp = do_winpattern(hand_tiles, fixed_tiles)
    case wp do
      nil -> :not_win
      [] -> :not_win
      :no_win_pattern -> :not_win
      _ -> {:win, wp}
    end 
  end

  # 2 tiles left. finding a pair of eye
  defp do_winpattern(tiles, fixed_tiles) when length(tiles) == 2 do
    case Tile.same(tiles) do
      true -> {Enum.sort([tiles | fixed_tiles])} # putting each win pattern list into a tuple to prevent flattening
      _else -> :no_win_pattern
    end
  end

  # more than 2 tiles left.
  defp do_winpattern(tiles, fixed_tiles) when rem(length(tiles),3) == 2 do
    case Tile.find_3(tiles) do
      [] -> :no_win_pattern
      fixed_list -> Enum.map(fixed_list, fn fixed -> 
                                           do_winpattern(tiles -- fixed, [fixed | fixed_tiles])
                                         end)
                    |> List.flatten
                    |> Enum.uniq
                    |> Enum.filter( fn result -> result != :no_win_pattern end )
    end
  end

  defp do_winpattern(_, _) do
    nil
  end

  defp play_order(last_player_id) do
    last_player_id + 1 .. last_player_id + 3
    |> Enum.map(&(rem(&1, 4)))
  end

  defp hand_of(pid, gInfo) do
    elem(gInfo.hands, pid)
  end

  ## { [{[hand_tiles], [fixed_tiles]} * 4], [remain covered tiles] }
  defp dispatch_tiles(jong) do
    game_tiles = Tile.all |> Enum.shuffle
    #game_tiles = Tile.all
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
