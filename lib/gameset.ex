defmodule GameSet do

  def win(tiles, fixed_tiles \\ []) do
    wp = do_winpattern(tiles, fixed_tiles)
    case wp do
      nil -> :not_win
      [] -> :not_win
      _ -> {:win, count_fan(wp)}
    end 
  end

  def winpattern(tiles) do
    do_winpattern(tiles, [])
  end

  # 2 tiles left. finding a pair of eye
  defp do_winpattern(tiles, fixed_tiles) when length(tiles) == 2 do
    case Tile.same(tiles) do
      true -> {[tiles | fixed_tiles]} # putting each win pattern list into a tuple to prevent flattening
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
                    |> Enum.filter( fn result -> result != :no_win_pattern end )
    end
  end

  defp do_winpattern(_, _) do
    nil
  end

  defp count_fan(win_patterns) do
    win_patterns
    |> Enum.map( fn {inner_win_pattern} -> do_count_fan(inner_win_pattern) end )
    |> Enum.reduce( fn ({{fan, _fan_types}, win_pattern} = cur, {{acc_fan, _acc_fan_types}, acc_win_pattern} = acc) ->
                          cond do
                            fan > acc_fan -> cur
                            true -> acc
                          end
                    end )
  end

  # Returning a tuple of { {total_number_of_fans, [ {number_of_fans, fan_pattern_type} ]}, original_win_pattern }
  defp do_count_fan(win_pattern) do
    mp = map_pattern(win_pattern)
    fans = [pungpung_fan(mp) ,
            pingwu_fan(mp) ,
            category_fan(win_pattern)]
            |> Enum.filter( fn {nfan, _fan_type} -> nfan > 0 end ) 

    # Summing all different fan types to get the final number of fan
    total_fan = fans |> Enum.reduce(0, fn ({nfan, _fan_type}, acc) -> acc + nfan end)
    {{total_fan, fans}, win_pattern}
  end

  # map the win pattern from winpattern() call to another pattern for easier counting fan
  defp map_pattern(win_pattern) do
    [_eye| remain] = win_pattern
    # We dont care the pair of eye.
    # eye is always at position 0 due to the recursion checking
    remain
    |> Enum.map( fn pattern -> 
                  cond do
                    Tile.pung(pattern) -> :Pung
                    Tile.sheung(pattern) -> :Sheung
                    true -> :Wrong
                    # todo: check flowers
                  end
                 end)
  end

  # Returning a tuple of {number_of_fans, :Pung}
  defp pungpung_fan(mp) do
    all_pung = mp |> Enum.reduce(true, fn (pattern, acc) -> acc && (pattern == :Pung) end)
    nfan = case all_pung do
      true -> 3
      _else -> 0
    end
    {nfan, :Pung}
  end

  # Returning a tuple of {number_of_fans, :PingWu}
  defp pingwu_fan(mp) do
    all_pung = mp |> Enum.reduce(true, fn (pattern, acc) -> acc && (pattern == :Sheung) end)
    nfan = case all_pung do
      true -> 1
      _else -> 0
    end
    {nfan, :PingWu}
  end

  # Returning a tuple of {number_of_fans, :SameCat | :MixCat}
  defp category_fan(wp) do
    categories = wp |> List.flatten
                    |> Enum.filter(fn tile -> tile.cat != :Flower end) # Skip flower when counting category fan
                    |> Enum.reduce([], fn (tile, acc) -> [tile.cat| acc] end)
                    |> Enum.uniq

    case length(categories) do
      1 -> {7, :SameCat} # All categories are the same for full hand. 
      2 -> cond do
            :Fan in categories -> {3, :MixCat} # Fan + another category
            true -> {0, :MixCat} # Mixing of Bamboo/Character/Dot
           end
      _Other -> {0, :MixCat}
    end
  end

  # Returning a tuple of {number_of_fans, :SameCat | :MixCat}
  defp dragon_fan(wp) do
  end

end

