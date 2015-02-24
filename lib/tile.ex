defmodule Tile do
  # category can be :bamboo :character :dot :fan :flower
  # sub-category can be :bamboo :character :dot :dragon :wind :flower
  # num from 1 - 9 for Bamboo/Character/Dot
  # num from 1 - 7 for Fan (Dragon/Wind)
  # num from 1 - 8 for Flower
  defstruct cat: :invalid, sub: :invalid, num: 0

  def same(t1, t2) do
    (t1.sub == t2.sub) && (t1.num == t2.num)
  end

  def same(tiles) do
    [h|_T] = tiles
    tiles
    |> Enum.reduce(true, fn(t,acc) -> acc && (t.sub == h.sub) && (t.num == h.num) end)
  end

  def gong([w, x, y, z]) do
    same([w, x, y, z])
  end

  def gong(_) do
    false
  end

  def pung([x, y, z]) do
    same([x, y, z])
  end

  def pung(_) do
    false
  end

  def sheung([_x, _y, _z] = inlist) do
    same_sub_3(inlist) && 
    consec_3(inlist) && 
    Enum.reduce(inlist, true, fn (t, acc) -> acc && t.cat in [:dot, :bamboo, :character] end)
  end

  def sheung(_) do
    false
  end

  def find_3(tiles) do
    # Assigning an id to it for smaller search range to find permutation
    t_tuples = Enum.zip(tiles |> Enum.sort(fn (l, r) -> l.num < r.num end ), 1..144)

    (for x <- t_tuples, y <- t_tuples -- [x], z <- (t_tuples -- [x]) -- [y], valid_3([elem(x, 0), elem(y, 0), elem(z, 0)]), elem(x, 1) <= elem(y, 1), elem(y, 1) <= elem(z, 1), do: [elem(x, 0), elem(y, 0), elem(z, 0)])
    |> Enum.uniq # do not count the same permutation twice for faster searching win pattern
  end

  def all(flowers \\ false) do
    # Every tile has 4 pieces
    all_patterns = (all_dots ++ all_bamboos ++ all_characters ++ all_fans)
                    |> Enum.flat_map( fn x -> [x,x,x,x] end )
    all_tiles = case flowers do
                 true -> all_patterns ++ all_flowers
                 _else -> all_patterns
               end

    # Assigning an id to it for easier to find permutation later on
    # Enum.zip(all_tiles, 1..144) |> Enum.map( fn tuple -> %{elem(tuple, 0) | id: elem(tuple, 1)} end )
    all_tiles
  end

  defp same_sub_3([x, y, z]) do
    x.sub == y.sub &&
    y.sub == z.sub
  end

  defp consec_3([x, y, z]) do
    mag = [x.num, y.num, z.num]
          |> Enum.sort 
    [min|_T] = mag
    [0, 1, 2] == mag |> Enum.map(fn n -> n - min end)
  end

  defp valid_3([x, y, z]) do
    sheung([x, y, z]) or pung([x, y, z])
  end

  defp all_bamboos do
    get_tiles(:bamboo, :bamboo, 9)
  end

  defp all_characters do
    get_tiles(:character, :character, 9)
  end

  defp all_dots do
    get_tiles(:dot, :dot, 9)
  end

  defp all_fans do
    all_winds ++ all_dragons
  end

  defp all_winds do
    get_tiles(:fan, :wind, 4)
  end

  defp all_dragons do
    get_tiles(:fan, :dragon, 7, 5)
  end

  defp all_flowers do
    get_tiles(:flower, :flower, 8)
  end

  defp get_tiles(cat, sub, to, from \\ 1) do
    from..to
    |> Enum.map(fn i -> %Tile{cat: cat, sub: sub, num: i} end)
  end
end
