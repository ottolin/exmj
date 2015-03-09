defmodule WinRule do

  def count_fan(win_patterns) do
    win_patterns
    |> Enum.map( fn {inner_win_pattern} -> do_count_fan(inner_win_pattern) end )
    |> Enum.reduce( fn ({{fan, _fan_types}, _win_pattern} = cur, {{acc_fan, _acc_fan_types}, _acc_win_pattern} = acc) ->
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
    #[_eye| remain] = win_pattern
    remain = win_pattern |> Enum.filter( fn x -> length(x) > 2 end )
    # We dont care the pair of eye.
    # eye is always at position 0 due to the recursion checking
    remain
    |> Enum.map( fn pattern -> 
                  cond do
                    Tile.pung(pattern) -> :pung
                    Tile.sheung(pattern) -> :sheung
                    Tile.gong(pattern) -> :gong
                    true -> :wrong
                    # TODO: check flowers
                  end
                 end)
  end

  # Returning a tuple of {number_of_fans, :pung}
  defp pungpung_fan(mp) do
    all_pung = mp |> Enum.reduce(true, fn (pattern, acc) -> acc && ((pattern == :pung) || (pattern == :gong)) end)
    nfan = case all_pung do
      true -> 3
      _else -> 0
    end
    {nfan, :pung}
  end

  # Returning a tuple of {number_of_fans, :pingwu}
  defp pingwu_fan(mp) do
    all_pung = mp |> Enum.reduce(true, fn (pattern, acc) -> acc && (pattern == :sheung) end)
    nfan = case all_pung do
      true -> 1
      _else -> 0
    end
    {nfan, :pingwu}
  end

  # Returning a tuple of {number_of_fans, :samecat | :mixcat}
  defp category_fan(wp) do
    categories = wp |> List.flatten
                    |> Enum.filter(fn tile -> tile.cat != :flower end) # Skip flower when counting category fan
                    |> Enum.reduce([], fn (tile, acc) -> [tile.cat| acc] end)
                    |> Enum.uniq

    case length(categories) do
      1 -> {7, :samecat} # All categories are the same for full hand. 
      2 -> cond do
            :fan in categories -> {3, :mixcat} # Fan + another category
            true -> {0, :mixcat} # Mixing of Bamboo/Character/Dot
           end
      _Other -> {0, :mixcat}
    end
  end

  # Returning a tuple of {number_of_fans, :samecat | :mixcat}
  defp dragon_fan(wp) do
  end

end

