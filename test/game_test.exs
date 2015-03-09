defmodule GameTest do
  use ExUnit.Case
  doctest Game

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

  def samecat() do
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

  def samecat2() do
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
      %Tile{cat: :dot, sub: :dot, num: 4},
      %Tile{cat: :dot, sub: :dot, num: 4},
      %Tile{cat: :dot, sub: :dot, num: 7},
      %Tile{cat: :dot, sub: :dot, num: 7}
    ]
  end

  test "PingWu win test" do
    gInfo = Game.new
    gInfo = %{gInfo | hands: put_elem(gInfo.hands, 0, {pingwu, []})}
    gInfo = %{gInfo | possiblePlayerMoves: Game.get_possible_moves(gInfo)}
    assert 14 == Enum.count(gInfo.possiblePlayerMoves, fn {_pid, move, _pattern} -> :discard == move end)
    assert 2 == Enum.count(gInfo.possiblePlayerMoves, fn {_pid, move, _pattern} -> :win == move end)
  end

  test "SameCat win test" do
    gInfo = Game.new
    gInfo = %{gInfo | hands: put_elem(gInfo.hands, 0, {samecat, []})}
    gInfo = %{gInfo | possiblePlayerMoves: Game.get_possible_moves(gInfo)}
    assert 14 == Enum.count(gInfo.possiblePlayerMoves, fn {_pid, move, _pattern} -> :discard == move end)
    assert 2 == Enum.count(gInfo.possiblePlayerMoves, fn {_pid, move, _pattern} -> :win == move end)

    fanlist = Enum.reduce(gInfo.possiblePlayerMoves, [], fn ({_pid, move, pattern}, acc) -> 
                                            case move do
                                              :win -> [WinRule.count_fan([pattern]) | acc]
                                              :discard -> acc
                                            end
                                            end)

    assert ([{{8, [{1, :pingwu},{7, :samecat}]}, _}, {{7, [{7, :samecat}]}, _}] = fanlist)
  end

  test "SameCat win test2" do
    gInfo = Game.new
    gInfo = %{gInfo | hands: put_elem(gInfo.hands, 0, {samecat2, []})}
    gInfo = %{gInfo | possiblePlayerMoves: Game.get_possible_moves(gInfo)}
    assert 14 == Enum.count(gInfo.possiblePlayerMoves, fn {_pid, move, _pattern} -> :discard == move end)
    assert 3 == Enum.count(gInfo.possiblePlayerMoves, fn {_pid, move, _pattern} -> :win == move end)

    fanlist = Enum.reduce(gInfo.possiblePlayerMoves, [], fn ({_pid, move, pattern}, acc) -> 
                                            case move do
                                              :win -> [WinRule.count_fan([pattern]) | acc]
                                              :discard -> acc
                                            end
                                            end)

    assert ([{{7, [{7, :samecat}]}, _}, {{7, [{7, :samecat}]}, _}, {{10, [{3, :pung},{7, :samecat}]}, _}] = fanlist)
  end
end
