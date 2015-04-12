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

  def test_hand1() do
    {
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
    ],
    []
    }
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

  test "Dark gong test" do
    gInfo = Game.new
    gInfo = %{gInfo | hands: put_elem(gInfo.hands, 0, test_hand1)}
    gInfo = %{gInfo | lastPlayerId: 3}
    gInfo = %{gInfo | lastPlayedTile: %Tile{cat: :dot, sub: :dot, num: 4}}
    gInfo = %{gInfo | possiblePlayerMoves: Game.get_possible_moves(gInfo)}

    assert (gInfo.possiblePlayerMoves ==
        [{0, :pung, [%Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}]},
        {0, :gong, [%Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}]},
        {0, :sheung, [%Tile{cat: :dot, num: 2, sub: :dot}, %Tile{cat: :dot, num: 3, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}]},
        {0, :draw, []}]
    )

    # First we simulate a pung
    gInfo = Game.action(gInfo, [{0, :pung, [%Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}]}])

    # Then, just pretend a round has been passed...
    gInfo = %{gInfo | lastPlayerId: 3}
    gInfo = %{gInfo | lastPlayedTile: :invalid}
    gInfo = %{gInfo | possiblePlayerMoves: Game.get_possible_moves(gInfo)}

    # Make sure it has the 1 dark gong right here
    assert (gInfo.possiblePlayerMoves ==
        [{0, :gong, [%Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}, %Tile{cat: :dot, num: 4, sub: :dot}]},
        {0, :discard, %Tile{cat: :dot, num: 1, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 1, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 1, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 2, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 2, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 2, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 3, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 3, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 3, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 4, sub: :dot}},
        {0, :discard, %Tile{cat: :dot, num: 7, sub: :dot}}]
    )
  end
end
