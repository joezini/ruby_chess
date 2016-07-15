require_relative '../chess'

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

	describe '#attacking_team' do
		it 'finds all squares under attack by enemy team' do
			board = Board.new
			board.set_starting_positions
			expect(board.attacking_team(:white)).to eq([[1,5],[0,5],[2,5],[3,5],[4,5],[5,5],[6,5],[7,5]])
		end
	end

	describe '#in_check' do
		it 'reports that a team is in check' do
			board = Board.new
			board.set_starting_positions
			board.placements[5][0] = Blank.new
			board.placements[4][1] = Rook.new(:black)
			expect(board.in_check(:white)).to be true
		end
	end

	describe '#in_checkmate' do
		it 'reports that a team is in checkmate' do
			board = Board.new
			board.set_starting_positions
			board.placements[5][0] = Blank.new
			board.placements[4][1] = Queen.new(:black)
			board.placements[5][2] = Pawn.new(:black)
			expect(board.in_checkmate(:white)).to be true
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

	describe '#move' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'can move 2 squares from start' do
			white_pawn = @board.placements[3][1]
			white_pawn.move(3,3,@board)
			expect(white_pawn.locate_self(@board)).to eq([3,3])
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
			@board.placements[0][0] = Blank.new
			@board.placements[0][1] = Blank.new
			white_pawn = @board.placements[4][1]
			@board.placements[4][3] = white_pawn
			@board.placements[4][1] = Blank.new
			expect(white_rook.valid_moves(@board)).to eq([[0,4],[0,5],[0,6],[0,2],[0,1],[0,0],[1,3],[2,3],[3,3]])
		end
	end

	describe '#move' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'cannot move from its starting position' do
			white_rook = @board.placements[0][0]
			expect(white_rook.move(0, 1, @board)).to be false
			expect(white_rook.locate_self(@board)).to eq([0, 0])
		end

		it 'can move vertically and capture an enemy pawn' do
			white_rook = @board.placements[0][0]
			@board.placements[0][1] = Blank.new
			expect(white_rook.move(0, 6, @board)).to be true
			expect(white_rook.locate_self(@board)).to eq([0, 6])
		end
	end
end

describe Knight do
	describe '#valid_moves' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'can move knightishly and capture enemy pieces' do
			white_knight = @board.placements[1][0]
			@board.placements[1][4] = white_knight
			@board.placements[1][0] = Blank.new
			white_pawn = @board.placements[2][1]
			@board.placements[2][2] = white_pawn
			@board.placements[2][1] = Blank.new
			expect(white_knight.valid_moves(@board)).to eq([[2,6],[3,5],[3,3],[0,2],[0,6]])
		end
	end

	describe '#move' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'can move from its start position' do
			white_knight = @board.placements[1][0]
			expect(white_knight.move(2, 2, @board)).to be true
			expect(white_knight.locate_self(@board)).to eq([2, 2])
		end		
	end
end

describe Bishop do
	describe '#valid_moves' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'can move diagonally and capture enemy pieces' do
			 white_bishop = @board.placements[5][0]
			 @board.placements[6][3] = white_bishop
			 @board.placements[5][0] = Blank.new
			 expect(white_bishop.valid_moves(@board)).to eq([[7,4],[7,2],[5,2],[5,4],[4,5],[3,6]])
		end
	end
end

describe Queen do
	describe '#valid_moves' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'can move orthogonally and diagonally, and capture enemy pieces' do
			white_queen = @board.placements[3][0]
			@board.placements[3][4] = white_queen
			@board.placements[3][0] = Blank.new
			expect(white_queen.valid_moves(@board)).to eq([[3,5],[3,6],[4,5],[5,6],
				[4,4],[5,4],[6,4],[7,4],[4,3],[5,2],[3,3],[3,2],[2,3],[1,2],[2,4],
				[1,4],[0,4],[2,5],[1,6]])
		end
	end
end

describe King do
	describe '#valid_moves' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
		end

		it 'can move 1 sq orthogonally and diagonally in open space' do
			white_king = @board.placements[4][0]
			@board.placements[3][2] = white_king
			@board.placements[4][0] = Blank.new
			expect(white_king.valid_moves(@board)).to eq([[3,3],[4,3],[4,2],[2,2],[2,3]])
		end

		it 'cannot place itself into check' do
			white_king = @board.placements[4][0]
			@board.placements[3][4] = white_king
			@board.placements[4][0] = Blank.new
			expect(white_king.valid_moves(@board)).to eq([[4,4],[4,3],[3,3],[2,3],[2,4]])
		end
	end

	describe '#move' do
		before :each do
			@board = Board.new
			@board.set_starting_positions
			@white_king = @board.placements[4][0]
			@white_rook = @board.placements[0][0]
			@board.placements[1][0] = Blank.new
			@board.placements[2][0] = Blank.new
			@board.placements[3][0] = Blank.new
		end

		it 'can castle to the left' do
			@white_king.move(2, 0, @board)
			expect(@white_king.locate_self(@board)).to eq([2, 0])
			expect(@white_rook.locate_self(@board)).to eq([3, 0])
		end		

		it 'can not castle once the rook has moved' do
			@white_rook.move(1, 0, @board)
			expect(@white_king.move(2, 0, @board)).to be false
			expect(@white_king.locate_self(@board)).to eq([4, 0])
			expect(@white_rook.locate_self(@board)).to eq([1, 0])
		end

		it 'can not castle if the intervening square is threatened' do
			@board.placements[3][1] = Rook.new(:black)
			expect(@white_king.move(2, 0, @board)).to be false
			expect(@white_king.locate_self(@board)).to eq([4, 0])
		end
	end
end