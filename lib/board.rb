class Board

  @@white_board_state = {'♔' => ['e1'], '♕' => ['d1'], '♖' => ['a1', 'h1'], '♗' => ['c1', 'f1'], '♘' => ['b1', 'g1'], '♙' => ['a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2']}

  @@black_board_state = {'♚' => ['e8'], '♛' => ['d8'], '♜' => ['a8', 'h8'], '♝' => ['c8', 'f8'], '♞' => ['b8', 'g8'], '♟' => ['a7', 'b7', 'c7', 'd7', 'e7', 'f7', 'g7', 'h7']}

  def initialize()
    @turn = 'white'
    @win = false
  end

  def print_board
    
  end

end