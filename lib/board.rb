module Pieces
  B_P_MOVES = [[0, -1], [-1, -1], [1, -1]]
  W_P_MOVES = [[0, 1], [-1, 1], [1, 1]]
  B_MOVES = [[-1, 1], [1, 1], [-1, -1], [1, -1]]
  N_MOVES = [[-1,-2], [-2,-1], [-2,1], [-1,2], [1,2], [2,1], [2,-1], [1,-2]]
  R_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1]]
  Q_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1], [-1, 1], [1, 1], [-1, -1], [1, -1]]
  K_MOVES = [[1, 0], [0, 1], [-1, 0], [0, -1], [-1, 1], [1, 1], [-1, -1], [1, -1]]

  def sum_arrays(arr1, arr2)
    [arr1, arr2].transpose.map { |x| x.sum }
  end

  def out_of_bounds(coord)
    !(coord[0].between?(1,8) && coord[1].between?(1,8))
  end

  def get_immediate_moves(position, moveset)
    # uses coordinate array
    immediate_moves = []
    moveset.each do |m|
      i_move = sum_arrays(position, m)
      immediate_moves.push(i_move) unless out_of_bounds(i_move)
    end
    immediate_moves
  end

  def piece_move(start, finish, piece)
    move_arr = [start]

    Board.piece_movesets[piece].each_with_index do |m, i|
      if i == 0 && ((piece == '♟' && start[1] == 2) || (piece == '♙' && start[1] == 7))
        2.times do
          move_arr.push(sum_arrays(move_arr.last, m))
          return move_arr if move_arr.last == finish
        end
      elsif ['♙', '♟', '♘', '♞', '♔', '♚'].any?(piece)
        move_arr.push(sum_arrays(move_arr.last, m))
        return move_arr if move_arr.last == finish
      else
        until out_of_bounds(move_arr.last)
          move_arr.push(sum_arrays(move_arr.last, m))
          return move_arr if move_arr.last == finish
        end
      end
      move_arr = [start]
    end

    return nil
  end

end

class Board
  include Pieces

  @black_board_state = {'♔' => ['e8'], '♕' => ['d8'], '♖' => ['a8', 'h8'], '♗' => ['c8', 'f8'], '♘' => ['b8', 'g8'], '♙' => ['a7', 'b7', 'c7', 'd7', 'e7', 'f7', 'g7', 'h7']}

  @white_board_state = {'♚' => ['e1'], '♛' => ['d1'], '♜' => ['a1', 'h1'], '♝' => ['c1', 'f1'], '♞' => ['b1', 'g1'], '♟' => ['a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2']}

  # @black_board_state = {'K' => ['e8'], 'Q' => ['d8'], 'R' => ['a8', 'h8'], 'B' => ['c8', 'f8'], 'N' => ['b8', 'g8'], 'P' => ['a7', 'b7', 'c7', 'd7', 'e7', 'f7', 'g7', 'h7']}

  # @white_board_state = {'K' => ['e1'], 'Q' => ['d1'], 'R' => ['a1', 'h1'], 'B' => ['c1', 'f1'], 'N' => ['b1', 'g1'], 'P' => ['a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2']}
  
  @board_spaces = {
    'a' => ['♜', '♟', ' ', ' ', ' ', ' ', '♙', '♖'],
    'b' => ['♞', '♟', ' ', ' ', ' ', ' ', '♙', '♘'], 
    'c' => ['♝', '♟', ' ', ' ', ' ', ' ', '♙', '♗'], 
    'd' => ['♛', '♟', ' ', ' ', ' ', ' ', '♙', '♕'], 
    'e' => ['♚', '♟', ' ', ' ', ' ', ' ', '♙', '♔'], 
    'f' => ['♝', '♟', ' ', ' ', ' ', ' ', '♙', '♗'], 
    'g' => ['♞', '♟', ' ', ' ', ' ', ' ', '♙', '♘'], 
    'h' => ['♜', '♟', ' ', ' ', ' ', ' ', '♙', '♖']
  }

  @player_boards = {'White' => @white_board_state, 'Black' => @black_board_state}

  @piece_movesets = {'♜' => R_MOVES, '♖' => R_MOVES, '♞' => N_MOVES, '♘' => N_MOVES, '♝' => B_MOVES, '♗' => B_MOVES, '♟' => W_P_MOVES, '♙' => B_P_MOVES, '♛' => Q_MOVES, '♕' => Q_MOVES, '♚' => K_MOVES, '♔' => K_MOVES}

  # Castle spaces array: K, R, K space, R space 
  @castle_states = {'White' => {'ooo' => [[5, 1], [1, 1], [3, 1], [4, 1]], 'oo' => [[5, 1], [8, 1], [7, 1], [6, 1]]}, 'Black' => {'ooo' => [[5, 8], [1, 8], [3, 8], [4, 8]], 'oo' => [[5, 8], [8, 8], [7, 8], [6, 8]]}}

  class << self
    attr_accessor :black_board_state, :white_board_state, :board_spaces, :player_boards, :piece_movesets, :castle_states
  end

  def initialize()

  end

  def create_board
    board = "\n╔═══╤═══╤═══╤═══╤═══╤═══╤═══╤═══╗╮\n║ "
  
    7.downto(0) do |i|
      Board.board_spaces.each_key do |k|
        if k == 'h'
          board += Board.board_spaces[k][i]
        else
          board += Board.board_spaces[k][i] + ' │ '
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

end
