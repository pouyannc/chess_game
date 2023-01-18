require_relative 'board.rb'

class Game
  include Pieces

  attr_accessor :turn, :opp, :checkmate, :board, :check, :valid_spaces_during_check

  def initialize
    @turn = 'White'
    @opp = 'Black'
    @checkmate = false
    @board = Board.new
    @check = false
  end

  def print_board
    puts @board.create_board
  end

  def check_within_bounds(coordinate)
    coordinate[0].between?('a', 'h') && coordinate[1].between?('1', '8')
  end

  def get_own_piece(position)
    # Returns piece at give position, else return nil
    Board.player_boards[@turn].each_pair { |piece, arr| return piece if arr.any?(position) }
    nil
  end

  def get_opp_piece(position)
    # Returns piece at give position, else return nil
    Board.player_boards[@opp].each_pair { |piece, arr| return piece if arr.any?(position) }
    nil
  end

  def valid_castle?(type)
    Board.castle_states[@turn][type] && !occupied_by_any?(Board.castle_states[@turn][type][2]) && !occupied_by_any?(Board.castle_states[@turn][type][3])
  end

  def valid_piece?(user_input)
    if user_input == 'ooo' || user_input == 'oo'
      return valid_castle?(user_input)
    elsif check_within_bounds(user_input) && Board.player_boards[@turn].flatten.flatten.any?(user_input)
      return !fully_blocked?(get_own_piece(user_input), user_input)
    else
      return false
    end
  end

  def get_move_piece
    puts "Enter the coordinate of a piece to move:\n"
    piece_space = gets.chomp.downcase

    if @check
      until @valid_spaces_during_check.any?(piece_space)
        puts "You must enter a valid coordinate (letter + number):\n"
        piece_space = gets.chomp.downcase
      end
    else
      until valid_piece?(piece_space)
        puts "You must enter a valid coordinate (letter + number):\n"
        piece_space = gets.chomp.downcase
      end

      return ['castle', piece_space] if piece_space == 'ooo' || piece_space == 'oo'
    end

    piece = get_own_piece(piece_space)
    [piece, piece_space]
  end

  def update_space(space, piece)
    Board.board_spaces[space[0]][space[1].to_i - 1] = piece
  end

  def player_boards_push(piece, position)
    Board.player_boards[@turn][piece].push(position)
  end

  def player_boards_del(piece, position)
    Board.player_boards[@turn][piece] -= [position]
  end

  def castle(type)
    king_piece, rook_piece = Board.player_boards[@turn].keys[0], Board.player_boards[@turn].keys[2]
    
    king_start = to_board_coord(Board.castle_states[@turn][type][0])
    rook_start = to_board_coord(Board.castle_states[@turn][type][1])

    king_end = to_board_coord(Board.castle_states[@turn][type][2])
    rook_end = to_board_coord(Board.castle_states[@turn][type][3])

    update_space(king_start, ' ')
    update_space(rook_start, ' ')

    update_space(king_end, king_piece)
    update_space(rook_end, rook_piece)

    player_boards_del(king_piece, king_start)
    player_boards_del(rook_piece, rook_start)

    player_boards_push(king_piece, king_end)
    player_boards_push(rook_piece, rook_end)

    Board.castle_states[@turn] = {}
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

  def create_temp_board(piece, start_arr, end_arr)
    temp_board = Board.board_spaces.dup.map { |k, v| [k, v.dup] }.to_h

    start_arr = to_board_coord(start_arr) unless start_arr.is_a?(String)
    end_arr = to_board_coord(end_arr) unless end_arr.is_a?(String)

    temp_board[start_arr[0]][start_arr[1].to_i - 1] = ' '
    temp_board[end_arr[0]][end_arr[1].to_i - 1] = piece
    temp_board
  end

  def get_king_space_arr(board, player)
    board.each_key do |c|
      board[c].each_with_index do |s, n|
        if s == Board.player_boards[player].keys[0]
          return to_coordinate_array(c + ((n+1).to_s))
        end
      end
    end
  end

  def get_piece_from_temp_board(board, space_arr)
    space = to_board_coord(space_arr)
    board[space[0]][space[1].to_i - 1]
  end

  def king_in_check?(piece, start_position, end_position, player)
    # Create updated temp_board with requested move and look for checks around the player's king
    temp_board = create_temp_board(piece, start_position, end_position)

    king_space = get_king_space_arr(temp_board, player)

    player == @turn ? opponent = @opp : opponent = @turn

    knight_checks = get_immediate_moves(king_space, N_MOVES)

    # Move through squares in each direction until out of bounds and look for pieces that put king in check
    K_MOVES.each_with_index do |d, i|
      current_space = sum_arrays(king_space, d)
      first_space = true
      until out_of_bounds(current_space)
        current_piece = get_piece_from_temp_board(temp_board, current_space)

        break if Board.player_boards[player][current_piece]

        if Board.player_boards[opponent][current_piece]
          return true if (Board.piece_movesets[current_piece] == K_MOVES && first_space) || 
                          Board.piece_movesets[current_piece] == Q_MOVES ||
                          (Board.piece_movesets[current_piece] == R_MOVES && i.between?(0,3)) || 
                          (Board.piece_movesets[current_piece] == B_MOVES && i.between?(4,7)) || 
                          (Board.piece_movesets[current_piece] == B_P_MOVES && i.between?(4,5) && first_space) || 
                          (Board.piece_movesets[current_piece] == W_P_MOVES && i.between?(6,7) && first_space)
        end

        current_space = sum_arrays(current_space, d)
        first_space = false
      end
    end

    # Look through all possible knight checks for opponent knight
    knight_checks.each do |s|
      current_piece = get_piece_from_temp_board(temp_board, s)
      return true if Board.player_boards[opponent][current_piece] && Board.piece_movesets[current_piece] == N_MOVES
    end

    false
  end

  def fully_blocked?(piece, position)
    #given board coordinate
    immediate_moves = get_immediate_moves(to_coordinate_array(position), Board.piece_movesets[piece])

    case piece
    when '♙' || '♟'
      3.times do |i|
        if i == 0
          return false unless occupied_by_any?(immediate_moves[i]) || king_in_check?(piece, position, immediate_moves[i], @turn)
        else
          return false if occupied_by_opp?(immediate_moves[i]) && !king_in_check?(piece, position, immediate_moves[i], @turn)
        end
      end
    else
      immediate_moves.each { |m| return false unless occupied_by_own?(m) || king_in_check?(piece, position, m, @turn) }
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

    return false if moves.nil? || blocked?(piece, moves) || (@check && king_in_check?(piece, s, e, @turn))

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

  def get_pawn_promo_piece
    letter_to_piece = {'Q' => Board.player_boards[@turn].keys[1], 'R' => Board.player_boards[@turn].keys[2], 'B' => Board.player_boards[@turn].keys[3], 'N' => Board.player_boards[@turn].keys[4]}
    puts "Enter piece to replace pawn [Q/R/N/B]: "
    promo_piece = gets.chomp.upcase
    until letter_to_piece.keys.any?(promo_piece)
      puts "You must enter a valid piece [Q/R/N/B]: "
      promo_piece = gets.chomp.upcase
    end

    letter_to_piece[promo_piece]
  end

  def move_piece(start_position, end_position, piece)
    # Update player_boards pieces that have been captured
    captured_piece = get_opp_piece(end_position)
    Board.player_boards[@opp][captured_piece] = [] unless captured_piece.nil?

    update_space(start_position, ' ')
    update_space(end_position, piece)

    player_boards_del(piece, start_position)
    player_boards_push(piece, end_position)

    # Update castle states if king or rooks are moved
    if piece == '♜' || piece == '♖'
      if start_position[0] == 'a' && Board.castle_states[@turn]['ooo']
        Board.castle_states[@turn].delete('ooo')
      elsif start_position[0] == 'h' && Board.castle_states[@turn]['oo']
        Board.castle_states[@turn].delete('oo')
      end
    elsif piece == '♚' || piece == '♔' && Board.castle_states[@turn] != {}
      Board.castle_states[@turn] = {}
    end
  end

  def any_valid_moves?(piece, position, pawn = false)
    # Given piece and its position, return true if there exists an open move where the king is not in check
    position_arr = to_coordinate_array(position)

    if pawn
      if (@turn == 'White' && position_arr[1] == 2) || (@turn == 'Black' && position_arr[1] == 7)
        2.times do
          next_position = sum_arrays(position_arr, Board.piece_movesets[piece][0])
          break if occupied_by_any?(next_position)
          return true if !king_in_check?(piece, position_arr, next_position, @turn)
          next_position = sum_arrays(next_position, Board.piece_movesets[piece][0])
        end
      end
      return !fully_blocked?(piece, position)
    end
        
    Board.piece_movesets[piece].each do |d|
      next_position = sum_arrays(position_arr, d)
      until out_of_bounds(next_position) || occupied_by_own?(next_position)
        return true if !king_in_check?(piece, position_arr, next_position, @turn)
        break if occupied_by_opp?(next_position)
        next_position = sum_arrays(next_position, d)
      end
    end

    false
  end

  def valid_pieces_when_check
    # Return the spaces of pieces that can make a valid move while king is in check
    valid_spaces = []
    Board.player_boards[@turn].each_with_index do |(k, v), i|
      case i
      when 0 || 4
        v.each { |s| valid_spaces.push(s) unless fully_blocked?(k, s) }
      when 1 || 2 || 3
        v.each { |s| valid_spaces.push(s) if any_valid_moves?(k, s) }
      else
        v.each { |s| valid_spaces.push(s) if any_valid_moves?(k, s, true) }
      end
    end

    valid_spaces
  end

  def end_screen
    puts "#{@opp} is the winner!"
  end

  def turn_script
    print_board

    if @check
      @valid_spaces_during_check = valid_pieces_when_check
      @checkmate = true if @valid_spaces_during_check.empty?
    end

    if @checkmate
      return end_screen
    else
      puts "\n#{@turn}'s turn"
      touched_piece, piece_space = get_move_piece

      if touched_piece == 'castle'
        # Need to disallow castle if king is in check while moving to castle space
        castle(piece_space)
      else
        end_position = get_end_position(touched_piece, piece_space)
        @check = true if king_in_check?(touched_piece, piece_space, end_position, @opp) # Checking if opponent king in check

        touched_piece = get_pawn_promo_piece if (touched_piece == '♙' && end_position[1] == '1') || (touched_piece == '♟' && end_position[1] == '8')

        move_piece(piece_space, end_position, touched_piece)
      end
    end

    @turn, @opp = @opp, @turn
  end

  def play
    until @checkmate do
      turn_script
    end
  end
end

#some similar functions like fully_blocked? any_valid_moves? and king_in_check? - could be refactored
#a2a3 e7e6 b2b3 d8h4 c2c3 f8c5 g2g4 h4f2
#what is left: pawn promotion, disallowing castle if it puts king in check, allow game to be saved, intro menu screen