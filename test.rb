class Test
  @test_class_var = "hello"

  class << self
    attr_accessor :test_class_var
  end

  def initialize
  end
end

puts Test.test_class_var
Test.test_class_var = "goodbye"
puts Test.test_class_var


board = '
╔═══╤═══╤═══╤═══╤═══╤═══╤═══╤═══╗╮
║ ♖ │ ♘ │ ♗ │ ♕ │ ♔ │ ♗ │ ♘ │ ♖ ║8
╟───┼───┼───┼───┼───┼───┼───┼───╢┊
║ ♙ │ ♙ │ ♙ │ ♙ │ ♙ │ ♙ │ ♙ │ ♙ ║7
╟───┼───┼───┼───┼───┼───┼───┼───╢┊
║   │   │   │   │   │   │   │   ║6
╟───┼───┼───┼───┼───┼───┼───┼───╢┊
║   │   │   │   │   │   │   │   ║5
╟───┼───┼───┼───┼───┼───┼───┼───╢┊
║   │   │   │   │   │   │   │   ║4
╟───┼───┼───┼───┼───┼───┼───┼───╢┊
║   │   │   │   │   │   │   │   ║3
╟───┼───┼───┼───┼───┼───┼───┼───╢┊
║ ♟ │ ♟ │ ♟ │ ♟ │ ♟ │ ♟ │ ♟ │ ♟ ║2
╟───┼───┼───┼───┼───┼───┼───┼───╢┊
║ ♜ │ ♞ │ ♝ │ ♛ │ ♚ │ ♝ │ ♞ │ ♜ ║1
╚═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╝┊
╰ a ┈ b ┈ c ┈ d ┈ e ┈ f ┈ g ┈ h ┈╯
'

hash = {'a' => ['♜', '♟', ' ', ' ', ' ', ' ', '♙', '♖'],
   'b' => ['♞', '♟', ' ', ' ', ' ', ' ', '♙', '♘'], 
   'c' => ['♝', '♟', ' ', ' ', ' ', ' ', '♙', '♗'], 
   'd' => ['♛', '♟', ' ', ' ', ' ', ' ', '♙', '♕'], 
   'e' => ['♚', '♟', ' ', ' ', ' ', ' ', '♙', '♔'], 
   'f' => ['♝', '♟', ' ', ' ', ' ', ' ', '♙', '♗'], 
   'g' => ['♞', '♟', ' ', ' ', ' ', ' ', '♙', '♘'], 
   'h' => ['♜', '♟', ' ', ' ', ' ', ' ', '♙', '♖']}

def create_board(hash)
  board = "\n╔═══╤═══╤═══╤═══╤═══╤═══╤═══╤═══╗╮\n║ "

  7.downto(0) do |i|
    hash.each_key do |k|
      if k == 'h'
        board += hash[k][i]
      else
        board += hash[k][i] + ' │ '
      end
    end
    if i == 0
      board += ' ║' + (i + 1).to_s
    else
      board += ' ║' + (i + 1).to_s + "\n╟───┼───┼───┼───┼───┼───┼───┼───╢┊\n║ "
    end
  end

  board += "\n╚═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╝┊\n╰ a ┈ b ┈ c ┈ d ┈ e ┈ f ┈ g ┈ h ┈╯\n"
end

puts create_board(hash)





B_P_MOVES = [[0, -1], [-1, -1], [1, -1]]

#function to check if piece can move from A to B.
def black_pawn_move(start, finish)
  move_arr = [start]
  
  B_P_MOVES.each_with_index do |m, i|
    if i == 0 && start[1] == 7
      2.times { move_arr += sum_arrays(move_arr.last, m) }
    else
      move_arr += sum_arrays(move_arr.last, m)
    end
    return move_arr if move_arr.last == finish
    move_arr = [start]
  end

  return nil
end