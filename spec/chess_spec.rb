require_relative '../chess'

empty_board = %Q(  __ __ __ __ __ __ __ __
8|__|__|__|__|__|__|__|__|
7|__|__|__|__|__|__|__|__|
6|__|__|__|__|__|__|__|__|
5|__|__|__|__|__|__|__|__|
4|__|__|__|__|__|__|__|__|
3|__|__|__|__|__|__|__|__|
2|__|__|__|__|__|__|__|__|
1|__|__|__|__|__|__|__|__|
   a  b  c  d  e  f  g  h)

start_board = %Q(  __ __ __ __ __ __ __ __
8|r_|n_|b_|q_|k_|b_|n_|r_|
7|p_|p_|p_|p_|p_|p_|p_|p_|
6|__|__|__|__|__|__|__|__|
5|__|__|__|__|__|__|__|__|
4|__|__|__|__|__|__|__|__|
3|__|__|__|__|__|__|__|__|
2|P_|P_|P_|P_|P_|P_|P_|P_|
1|R_|N_|B_|Q_|K_|B_|N_|R_|
   a  b  c  d  e  f  g  h)

describe Board do
	describe '#as_string' do
		it 'populates the starting position' do
			board = Board.new
			board.set_starting_positions
			expect(board.as_string).to eq(start_board)
		end
	end
end

describe Pawn do
	describe '#locate_self' do
		it 'can find its location on the board' do
			@board = Board.new
			@board.set_starting_positions
			white_pawn = @board.placements[2][1]
			expect(white_pawn.locate_self(@board)).to eq([2,1])
		end
	end

	describe '#valid_moves' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'can move 1 or 2 square at the start' do
			white_pawn = @board.placements[2][1]
			expect(white_pawn.valid_moves(@board)).to eq([[2,2],[2,3]])
			black_pawn = @board.placements[3][6]
			expect(black_pawn.valid_moves(@board)).to eq([[3,5],[3,4]])
		end

		it 'can only move 1 square after it has started moving' do
			white_pawn = @board.placements[3][1]
			@board.placements[3][2] = white_pawn
			white_pawn.has_moved = true
			@board.placements[3][1] = Blank.new
			expect(white_pawn.valid_moves(@board)).to eq([[3,3]])
			black_pawn = @board.placements[4][6]
			@board.placements[4][5] = black_pawn
			@board.placements[4][6] = Blank.new
			black_pawn.has_moved = true
			expect(black_pawn.valid_moves(@board)).to eq([[4,4]])
		end

		it 'can move diagonally if there is an enemy piece to capture' do
			white_pawn = @board.placements[3][1]
			@board.placements[3][2] = white_pawn
			white_pawn.has_moved = true
			@board.placements[3][1] = Blank.new
			black_pawn = @board.placements[4][6]
			@board.placements[4][3] = black_pawn
			@board.placements[4][6] = Blank.new
			black_pawn.has_moved = true
			expect(white_pawn.valid_moves(@board)).to eq([[3,3],[4,3]])
		end
	end
end

describe Rook do
	describe '#valid_moves' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'cannot move at the start of the game' do
			white_rook = @board.placements[0][0]
			expect(white_rook.valid_moves(@board)).to eq([])
		end

		it 'can move vertically and horizontally and capture enemy pieces' do
			white_rook = @board.placements[0][0]
			@board.placements[0][3] = white_rook
			@board.placements[0][1] = Blank.new
			white_pawn = @board.placements[4][1]
			@board.placements[4][3] = white_pawn
			@board.placements[4][1] = Blank.new
			expect(white_rook.valid_moves(@board)).to eq([[0,4],[0,5],[0,6],[0,2],[0,1],[0,0],[1,3],[2,3],[3,3]])
		end
	end
end