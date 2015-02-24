defmodule TileTest do
  use ExUnit.Case
  doctest Tile

  def pingwu do
    [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 4},
      %Tile{cat: :dot, sub: :dot, num: 5},
      %Tile{cat: :dot, sub: :dot, num: 6},
      %Tile{cat: :bamboo, sub: :bamboo, num: 1},
      %Tile{cat: :bamboo, sub: :bamboo, num: 1}
    ]
  end

  def gg() do
    [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 4},
      %Tile{cat: :dot, sub: :dot, num: 5},
      %Tile{cat: :dot, sub: :dot, num: 6},
      %Tile{cat: :dot, sub: :dot, num: 7},
      %Tile{cat: :dot, sub: :dot, num: 7}
    ]
  end

  test "Same tiles" do
    s = [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
    ]
    assert Tile.same(s)

    s = [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 3},
    ]
    assert !Tile.same(s)

    s = [ %Tile{cat: :bamboo, sub: :bamboo, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :flower, sub: :flower, num: 1},
    ]
    assert !Tile.same(s)
  end

  test "Pung" do
    s = [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
    ]
    assert Tile.pung(s)
  end

  test "Not Pung" do
    s = [ %Tile{cat: :bamboo, sub: :bamboo, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :flower, sub: :flower, num: 1},
    ]
    assert !Tile.pung(s)
  end

  test "Not Pung 2" do
    s = [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
    ]
    assert !Tile.pung(s)
  end

  test "Gong" do
    s = [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
    ]
    assert Tile.gong(s)
  end

  test "Not Gong" do
    s = [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
    ]
    assert !Tile.gong(s)
  end
  test "Sheung" do
    s = [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 3},
    ]
    assert Tile.sheung(s)
  end

  test "Sheung invalid" do
    s = [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 1},
    ]
    assert !Tile.sheung(s)
  end

  test "Sheung Fans" do
    s = [ %Tile{cat: :fan, sub: :wind, num: 1},
      %Tile{cat: :fan, sub: :wind, num: 2},
      %Tile{cat: :fan, sub: :wind, num: 3},
    ]
    assert !Tile.sheung(s)
  end

  test "Sheung Flowers" do
    s = [ %Tile{cat: :flower, sub: :flower, num: 1},
      %Tile{cat: :flower, sub: :flower, num: 2},
      %Tile{cat: :flower, sub: :flower, num: 3},
    ]
    assert !Tile.sheung(s)
  end

  test "all tiles no flowers" do
    assert 136 == Tile.all |> Enum.count
  end

  test "all tiles" do
    assert 144 == Tile.all(true) |> Enum.count
  end

  test "find 3 1" do
    s = [ %Tile{cat: :dot, sub: :dot, num: 1},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 2},
      %Tile{cat: :dot, sub: :dot, num: 3},
      %Tile{cat: :dot, sub: :dot, num: 4},
      %Tile{cat: :dot, sub: :dot, num: 4},
      %Tile{cat: :dot, sub: :dot, num: 4},
    ]

    expected = [[%Tile{cat: :dot, num: 1, sub: :dot}, %Tile{cat: :dot, num: 2, sub: :dot}, %Tile{cat: :dot, num: 3, sub: :dot}],
            [%Tile{cat: :dot, num: 2, sub: :dot}, %Tile{cat: :dot, num: 2, sub: :dot}, %Tile{cat: :dot, num: 2, sub: :dot}],
            [%Tile{cat: :dot, num: 2, sub: :dot}, %Tile{cat: :dot, num: 3, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}],
            [%Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}]] 
    assert expected == Tile.find_3(s)
  end

  test "find 3 2" do
    s = [ %Tile{cat: :wind, sub: :wind, num: 1},
      %Tile{cat: :wind, sub: :wind, num: 2},
      %Tile{cat: :wind, sub: :wind, num: 3},
      %Tile{cat: :wind, sub: :wind, num: 2},
      %Tile{cat: :wind, sub: :wind, num: 2},
      %Tile{cat: :wind, sub: :wind, num: 3},
      %Tile{cat: :wind, sub: :wind, num: 4},
      %Tile{cat: :wind, sub: :wind, num: 4},
      %Tile{cat: :wind, sub: :wind, num: 4},
    ]

    expected = [[%Tile{cat: :wind, num: 2, sub: :wind}, %Tile{cat: :wind, num: 2, sub: :wind}, %Tile{cat: :wind, num: 2, sub: :wind}],
                [%Tile{cat: :wind, num: 4, sub: :wind}, %Tile{cat: :wind, num: 4, sub: :wind}, %Tile{cat: :wind, num: 4, sub: :wind}]] 
    assert expected == Tile.find_3(s)
  end
end
