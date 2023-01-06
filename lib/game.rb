require_relative 'board.rb'

class Game
  include Pieces

  attr_accessor :turn, :win, :board

  def initialize
    @turn = 'White'
    @opp = 'Black'
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

  def get_own_piece(position)
    Board.player_boards[@turn].each_pair { |piece, arr| return piece if arr.any?(position) }
    nil
  end

  def get_move_piece
    puts "Enter the coordinate of a piece to move:\n"
    piece_space = gets.chomp.downcase

    until check_within_bounds(piece_space) && Board.player_boards[@turn].flatten.flatten.any?(piece_space)
      puts "You must enter a valid coordinate (letter + number):\n"
      piece_space = gets.chomp.downcase
    end
    piece = get_own_piece(piece_space)

    [piece, piece_space]
  end

  def to_coordinate_array(board_coord)
    x = board_coord[0].ord - 96
    y = board_coord[1].to_i
    [x, y]
  end

  def to_board_coord(coord_arr)
    (coord_arr[0] + 96).chr + coord_arr[1].to_s
  end

  def occupied_by_any?(coord_arr)
    !(Board.board_spaces[to_board_coord(coord_arr)[0]][coord_arr[1] - 1] == ' ')
  end

  def occupied_by_opp?(coord_arr)
    Board.player_boards[@opp].keys.any?(Board.board_spaces[to_board_coord(coord_arr)[0]][coord_arr[1] - 1])
  end

  def occupied_by_own?(coord_arr)
    Board.player_boards[@turn].keys.any?(Board.board_spaces[to_board_coord(coord_arr)[0]][coord_arr[1] - 1]) 
  end

  def fully_blocked?(piece, position)
    immediate_moves = get_immediate_moves(to_coordinate_array(position), Board.piece_movesets[piece])

    case piece
    when '♙' || '♟'
      if !occupied_by_any?(immediate_moves[0]) || occupied_by_opp?(immediate_moves[1]) || occupied_by_opp?(immediate_moves[2])
        return false
      end

    when '♚' || '♔'
      immediate_moves.each { |m| return false unless occupied_by_own?(m) }
      # king has special conditions... cannot move into capture

    else
      immediate_moves.each { |m| return false unless occupied_by_own?(m) }

    end

    true
  end

  def blocked?(piece, moves_arr)
    moves_arr.each_with_index do |s, i|
      if i == 0
        next
      elsif i == moves_arr.length - 1
        if (piece == '♙' || piece == '♟')
          if moves_arr.last[0] != moves_arr.first[0]
            return true if !occupied_by_opp?(s)
          else
            return true if occupied_by_any?(s)
          end
        else
          return true if occupied_by_own?(s)
        end
      else
        return true if occupied_by_any?(s)
      end
    end

    false
  end

  def valid_move?(piece, s, e) # return true or false if move is valid
    s_coord = to_coordinate_array(s)
    e_coord = to_coordinate_array(e)

    moves = piece_move(s_coord, e_coord, piece)

    return false if moves.nil? || blocked?(piece, moves)

    return true
  end

  def get_end_position(piece, start_position)
    puts "Enter the coordinate of the space to move selected piece:\n"
    end_position = gets.chomp.downcase

    until start_position != end_position && check_within_bounds(end_position) && valid_move?(piece, start_position, end_position)
      puts "You must enter a valid coordinate (letter + number) of a legal move:\n"
      end_position = gets.chomp.downcase
    end
    end_position
  end

  def move_piece(start_position, end_position, piece)
    #update board spaces after validating move
    Board.board_spaces[start_position[0]][start_position[1].to_i - 1] = ' '
    Board.board_spaces[end_position[0]][end_position[1].to_i - 1] = piece
    Board.player_boards[@turn][piece] -= [start_position]
    Board.player_boards[@turn][piece].push(end_position)
  end

  def turn_script
    print_board
    touched_piece, piece_space = get_move_piece

    while fully_blocked?(touched_piece, piece_space)
      puts "Can't move that piece..."
      touched_piece, piece_space = get_move_piece
    end
    end_position = get_end_position(touched_piece, piece_space)
    move_piece(piece_space, end_position, touched_piece)
  end

end