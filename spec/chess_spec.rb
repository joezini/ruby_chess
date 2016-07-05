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
		it 'outputs an empty board string' do
			board = Board.new
			expect(board.as_string).to eq(empty_board)
		end

		it 'populates the starting position' do
			board = Board.new
			board.set_starting_positions
			expect(board.as_string).to eq(start_board)
		end
	end
end

describe Pawn do
	describe '#valid_moves' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'can move 1 or 2 square at the start' do
			white_pawn = @board.placements[1][2]
			expect(white_pawn.valid_moves([1,2], @board)).to eq([[2,2],[3,2]])
			black_pawn = @board.placements[6][3]
			expect(black_pawn.valid_moves([6,3], @board)).to eq([[5,3],[4,3]])
			# agh the coordinates are a mess! Get this working in a nice Cartesian way...
		end

		xit 'can only move 1 square after it has started moving' do
			# need to move the pawns
			white_pawn = # select one of the pawns already on the board
			white_pawn.has_moved = true
			expect(white_pawn.valid_moves([3,2])).to eq([[3,3]])
			black_pawn = Pawn.new("b")
			black_pawn.has_moved = true
			expect(black_pawn.valid_moves([4,5])).to eq([[4,4]])
		end

		xit 'can move diagonally if there is an enemy piece to capture' do
			white_pawn = Pawn.new("w")
		end
	end
end