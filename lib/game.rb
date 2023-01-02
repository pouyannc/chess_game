require_relative 'board.rb'

class Game
  include Pieces

  attr_accessor :turn, :win, :board

  def initialize
    @turn = 'White'
    @win = false
    @board = Board.new
  end

  def print_board
    puts @board.create_board
    puts "\n#{@turn}'s turn"
  end

  def check_within_bounds(coordinate)
    coordinate[0].between?('a', 'h') && coordinate[1].between?('1', '8')
  end

  def get_move_piece
    puts "Enter the coordinate of a piece to move:\n"
    piece_space = gets.chomp.downcase

    until check_within_bounds(piece_space) && Board.player_boards[@turn].flatten.flatten.any?(piece_space)
      puts "You must enter a valid coordinate (letter + number):\n"
      piece_space = gets.chomp.downcase
    end

    [Board.player_boards[@turn].key(piece_space), piece_space]
  end

  def to_coordinate_array(board_coord)
    x = board_coord[0].ord - 96
    y = board_coord[1].to_i
    [x, y]
  end

  def piece_move(piece, s, e)
    #return array of moves to get from s to e.
    case piece
    when '♙'
      black_pawn_move(s, e)
    when '♟'
      white_pawn_move(s, e)
    when '♝' || '♗'
      bishop_move(s, e)
    when '♞' || '♘'

    when '♜' || '♖'

    when '♛' || '♕'

    when '♚' || '♔'

    end


  end

  def check_move(piece, s, e) # return true or false if move is valid
    s_coord = to_coordinate_array(s)
    e_coord = to_coordinate_array(e)

    moves = piece_move(piece, s_coord, e_coord)

    return false if moves.nil? || blocked?(piece, moves)

    return true
  end

  def get_end_position(piece, start_position)
    puts "Enter the coordinate of the space to move selected piece:\n"
    end_position = gets.chomp.downcase

    #need to check if valid move
    until check_within_bounds(end_position) && check_move(piece, start_position, end_position)
      puts "You must enter a valid coordinate (letter + number) of a legal move:\n"
      end_position = gets.chomp.downcase
    end
    end_position
  end

  def move_piece

  end

  def turn_script
    print_board
    touched_piece, piece_space = get_move_piece
    end_position = get_end_position(touched_piece, piece_space)
    #update board by updating board variables using touched_piece and end_position
    move_piece(piece_space, end_position)
  end

end