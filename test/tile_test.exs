defmodule TileTest do
  use ExUnit.Case
  doctest Tile

  def pingwu do
    [ %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
      %Tile{cat: :Dot, sub: :Dot, num: 4},
      %Tile{cat: :Dot, sub: :Dot, num: 5},
      %Tile{cat: :Dot, sub: :Dot, num: 6},
      %Tile{cat: :Bamboo, sub: :Bamboo, num: 1},
      %Tile{cat: :Bamboo, sub: :Bamboo, num: 1}
    ]
  end

  def gg() do
    [ %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
      %Tile{cat: :Dot, sub: :Dot, num: 4},
      %Tile{cat: :Dot, sub: :Dot, num: 5},
      %Tile{cat: :Dot, sub: :Dot, num: 6},
      %Tile{cat: :Dot, sub: :Dot, num: 7},
      %Tile{cat: :Dot, sub: :Dot, num: 7}
    ]
  end

  test "Same tiles" do
    s = [ %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
    ]
    assert Tile.same(s)

    s = [ %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
    ]
    assert !Tile.same(s)

    s = [ %Tile{cat: :Bamboo, sub: :Bamboo, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Flower, sub: :Flower, num: 1},
    ]
    assert !Tile.same(s)
  end

  test "Pung" do
    s = [ %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
    ]
    assert Tile.pung(s)
  end

  test "Not Pung" do
    s = [ %Tile{cat: :Bamboo, sub: :Bamboo, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Flower, sub: :Flower, num: 1},
    ]
    assert !Tile.pung(s)
  end

  test "Sheung" do
    s = [ %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
    ]
    assert Tile.sheung(s)
  end

  test "Sheung invalid" do
    s = [ %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 1},
    ]
    assert !Tile.sheung(s)
  end

  test "Sheung Fans" do
    s = [ %Tile{cat: :Fan, sub: :Wind, num: 1},
      %Tile{cat: :Fan, sub: :Wind, num: 2},
      %Tile{cat: :Fan, sub: :Wind, num: 3},
    ]
    assert !Tile.sheung(s)
  end

  test "Sheung Flowers" do
    s = [ %Tile{cat: :Flower, sub: :Flower, num: 1},
      %Tile{cat: :Flower, sub: :Flower, num: 2},
      %Tile{cat: :Flower, sub: :Flower, num: 3},
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
    s = [ %Tile{cat: :Dot, sub: :Dot, num: 1},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 2},
      %Tile{cat: :Dot, sub: :Dot, num: 3},
      %Tile{cat: :Dot, sub: :Dot, num: 4},
      %Tile{cat: :Dot, sub: :Dot, num: 4},
      %Tile{cat: :Dot, sub: :Dot, num: 4},
    ]

    expected = [[%Tile{cat: :Dot, num: 1, sub: :Dot}, %Tile{cat: :Dot, num: 2, sub: :Dot}, %Tile{cat: :Dot, num: 3, sub: :Dot}],
            [%Tile{cat: :Dot, num: 2, sub: :Dot}, %Tile{cat: :Dot, num: 2, sub: :Dot}, %Tile{cat: :Dot, num: 2, sub: :Dot}],
            [%Tile{cat: :Dot, num: 2, sub: :Dot}, %Tile{cat: :Dot, num: 3, sub: :Dot}, %Tile{cat: :Dot, num: 4, sub: :Dot}],
            [%Tile{cat: :Dot, num: 4, sub: :Dot}, %Tile{cat: :Dot, num: 4, sub: :Dot}, %Tile{cat: :Dot, num: 4, sub: :Dot}]] 
    assert expected == Tile.find_3(s)
  end

  test "find 3 2" do
    s = [ %Tile{cat: :Wind, sub: :Wind, num: 1},
      %Tile{cat: :Wind, sub: :Wind, num: 2},
      %Tile{cat: :Wind, sub: :Wind, num: 3},
      %Tile{cat: :Wind, sub: :Wind, num: 2},
      %Tile{cat: :Wind, sub: :Wind, num: 2},
      %Tile{cat: :Wind, sub: :Wind, num: 3},
      %Tile{cat: :Wind, sub: :Wind, num: 4},
      %Tile{cat: :Wind, sub: :Wind, num: 4},
      %Tile{cat: :Wind, sub: :Wind, num: 4},
    ]

    expected = [[%Tile{cat: :Wind, num: 2, sub: :Wind}, %Tile{cat: :Wind, num: 2, sub: :Wind}, %Tile{cat: :Wind, num: 2, sub: :Wind}],
                [%Tile{cat: :Wind, num: 4, sub: :Wind}, %Tile{cat: :Wind, num: 4, sub: :Wind}, %Tile{cat: :Wind, num: 4, sub: :Wind}]] 
    assert expected == Tile.find_3(s)
  end
end
