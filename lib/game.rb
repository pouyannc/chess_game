require_relative 'board.rb'

class Game

  def initialize
    @turn = 'White'
    @win = false
    @board = Board.new
  end

  def print_board
    puts @board.create_board
    puts "\n#{@turn}'s turn"
  end

  def get_move_piece
    puts 'Enter the coordinate of a piece to move:'
    piece_space = gets.chomp.downcase
  end

  def turn_script
    print_board
    get_move_piece
  end

  def move_piece

  end

end