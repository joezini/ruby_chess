# TODO
# Implement en passent - I think there needs to be a turn counter for
#    this since you can only capture a pawn that moved on the prev turn, so
#    will return to this after implementing the game loop
# Implement Castling - need to add "has_moved?" booleans for the rooks
# and King to make sure that it's allowed => need to write move methods first

module Locate
	def locate_self(board)
		(0..7).each do |i|
			(0..7).each do |j|
				if board.placements[i][j] == self
					return [i, j]
				end
			end
		end
	end

	def on_board(i, j)
		if i >= 0 && i <= 7 && j >= 0 && j <= 7
			true
		else
			false
		end
	end

	def next_square(x, y, dir)
		case dir
		when "ne"
		  [x + 1, y + 1]
		when "se"
		  [x + 1, y - 1]
		when "sw"
		  [x - 1, y - 1]
		when "nw"
		  [x - 1, y + 1]
	  	when "up"
		  [x, y + 1]
		when "down"
		  [x, y - 1]
		when "left"
		  [x - 1, y]
		when "right"
		  [x + 1, y]
		end
	end

	def check_line_from(x, y, dir, board)
		blocked = false
		moves = []
		until blocked || !on_board(x, y) do
			next_x, next_y = next_square(x, y, dir)
			if on_board(next_x, next_y) && board.placements[next_x][next_y].is_blank
				moves << [next_x, next_y]
			elsif on_board(next_x,next_y) && !board.placements[next_x][next_y].is_blank
				if board.placements[next_x][next_y].team != @team
					moves << [next_x, next_y]
				end
				blocked = true
			end
			x,y = next_x, next_y
		end
		moves
	end

	def move(x, y, board)
	 	if self.valid_moves(board).include?([x, y])
	 		current_x, current_y = self.locate_self(board)
	 		if !board.placements[x][y].is_blank
	 			# capture piece at x, y
	 		else
	 			board.placements[x][y] = self
	 			board.placements[current_x][current_y] = Blank.new
	 		end
	 	end

	end
end

class Board
	attr_accessor :placements

	def initialize
		@placements = Array.new(8) {Array.new(8, nil)}
	end

	def as_string
		output = " "
		8.times { output << " __" }
		output << "\n"
		7.downto(0) do |j|
			output << (j+1).to_s + "|"
			0.upto(7) do |i|
				output << @placements[i][j].symbol + "_|"
			end
			output << "\n"
		end
		output << "   a  b  c  d  e  f  g  h"

		output
	end

	def set_starting_positions
		def set_major_row(team)
			if team == :white
				row = 0
			elsif team == :black
				row = 7
			end
			@placements[0][row] = Rook.new(team)
			@placements[1][row] = Knight.new(team)
			@placements[2][row] = Bishop.new(team)
			@placements[3][row] = Queen.new(team)
			@placements[4][row] = King.new(team)
			@placements[5][row] = Bishop.new(team)
			@placements[6][row] = Knight.new(team)
			@placements[7][row] = Rook.new(team)
		end

		def set_pawn_row(team)
			if team == :white
				row = 1
			elsif team == :black
				row = 6
			end
			(0..7).each do |i| 
				@placements[i][row] = Pawn.new(team)
			end
		end

		def set_blank_rows
			(2..5).each do |j|
				(0..7).each do |i|
					@placements[i][j] = Blank.new
				end
			end
		end

		set_major_row(:white)
		set_pawn_row(:white)
		set_blank_rows
		set_pawn_row(:black)
		set_major_row(:black)
	end

	def attacking_team(team)
		attacked = []
		@placements.each do |col|
			col.each do |square|
				if !square.is_blank && square.team != team && square.class != King
					square.attacking(self).each do |under_attack|
						attacked << under_attack
					end
				end
			end
		end
		attacked.uniq
	end
end

class King
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == :white
			@symbol = "K"
		else
			@symbol = "k"
		end
	end

	def is_blank
		false
	end

	def find_enemy_king(board)
		(0..7).each do |i|
			(0..7).each do |j|
				if board.placements[i][j].class == King && board.placements[i][j].team != @team
					return [i, j]
				end
			end
		end
	end

	def valid_moves(board)
		i,j = locate_self(board)
		ex,ey = find_enemy_king(board)
		moves = []
		attacked = board.attacking_team(@team)

		def attacked_by_enemy_king?(x, y, enemy_x, enemy_y)
			if (enemy_x - x).abs <= 1 && (enemy_y - y).abs <= 1
				return true
			else
				return false
			end
		end

		def check_direction(x, y, dir, board, attacked, enemy_king_x, enemy_king_y)
			move = []
			next_x, next_y = next_square(x, y, dir)

			if on_board(next_x, next_y) && !attacked.include?([next_x,next_y]) && !attacked_by_enemy_king?(next_x,next_y,enemy_king_x,enemy_king_y)
				if board.placements[next_x][next_y].is_blank || board.placements[next_x][next_y].team != @team
					move << [next_x, next_y]
				end
			end
	
			move
		end

		moves += check_direction(i, j, "up", board, attacked, ex, ey)
		moves += check_direction(i, j, "ne", board, attacked, ex, ey)
		moves += check_direction(i, j, "right", board, attacked, ex, ey)
		moves += check_direction(i, j, "se", board, attacked, ex, ey)
		moves += check_direction(i, j, "down", board, attacked, ex, ey)
		moves += check_direction(i, j, "sw", board, attacked, ex, ey)
		moves += check_direction(i, j, "left", board, attacked, ex, ey)
		moves += check_direction(i, j, "nw", board, attacked, ex, ey)

		moves
	end

	def attacking(board)
		valid_moves(board)
	end
end

class Queen
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == :white
			@symbol = "Q"
		else
			@symbol = "q"
		end
	end

	def is_blank
		false
	end

	def valid_moves(board)
		i,j = locate_self(board)
		moves = []

		moves += check_line_from(i, j, "up", board)
		moves += check_line_from(i, j, "ne", board)
		moves += check_line_from(i, j, "right", board)
		moves += check_line_from(i, j, "se", board)
		moves += check_line_from(i, j, "down", board)
		moves += check_line_from(i, j, "sw", board)
		moves += check_line_from(i, j, "left", board)
		moves += check_line_from(i, j, "nw", board)

		moves
	end

	def attacking(board)
		valid_moves(board)
	end
end

class Bishop
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == :white
			@symbol = "B"
		else
			@symbol = "b"
		end
	end

	def is_blank
		false
	end

	def valid_moves(board)
		i,j = locate_self(board)
		moves = []

		moves += check_line_from(i, j, "ne", board)
		moves += check_line_from(i, j, "se", board)
		moves += check_line_from(i, j, "sw", board)
		moves += check_line_from(i, j, "nw", board)

		moves
	end

	def attacking(board)
		valid_moves(board)
	end
end

class Knight
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == :white
			@symbol = "N"
		else
			@symbol = "n"
		end
	end

	def is_blank
		false
	end

	def valid_moves(board)
		i,j = locate_self(board)
		moves = []
		possible_moves = [[1,2],[2,1],[2,-1],[1,-2],[-1,-2],[-2,-1],[-2,1],[-1,2]]
		possible_moves.each do |x, y|
			if on_board(i+x, j+y)
				if board.placements[i+x][j+y].is_blank
					moves << [i+x, j+y]
				elsif !board.placements[i+x][j+y].is_blank && board.placements[i+x][j+y].team != @team
					moves << [i+x, j+y]
				end
			end
		end
		moves
	end

	def attacking(board)
		valid_moves(board)
	end
end

class Rook
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == :white
			@symbol = "R"
		else
			@symbol = "r"
		end
	end

	def is_blank
		false
	end

	def valid_moves(board)
		i,j = locate_self(board)
		moves = []

		moves += check_line_from(i, j, "up", board)
		moves += check_line_from(i, j, "down", board)
		moves += check_line_from(i, j, "left", board)
		moves += check_line_from(i, j, "right", board)

		moves
	end

	def attacking(board)
		valid_moves(board)
	end
end

class Pawn
	include Locate
	attr_accessor :team, :symbol, :has_moved

	def initialize(team)
		@team = team
		if team == :white
			@symbol = "P"
		else
			@symbol = "p"
		end
		@has_moved = false
	end

	def is_blank
		false
	end

	def next_row(j, no_rows)
		if @team == :white
			j + no_rows
		else
			j - no_rows
		end
	end

	def on_board(x)
		if x >= 0 && x <= 7
			true
		else
			false
		end
	end

	def valid_moves(board)
		i,j = locate_self(board)
		moves = []
		blocked = false

		if on_board(next_row(j,1)) && board.placements[i][next_row(j,1)].is_blank
			moves << [i, next_row(j,1)]
		else
			blocked = true
		end
		if !@has_moved && board.placements[i][next_row(j,2)].is_blank && !blocked
			moves << [i, next_row(j,2)]
		end
		if on_board(next_row(j,1))
			if on_board(i - 1)
				if !board.placements[i - 1][next_row(j,1)].is_blank && board.placements[i - 1][next_row(j,1)].team != @team
					moves << [i - 1, next_row(j,1)]
				end
			end
			if on_board(i + 1)
				if !board.placements[i + 1][next_row(j,1)].is_blank && board.placements[i + 1][next_row(j,1)].team != @team
					moves << [i + 1, next_row(j,1)]
				end
			end
		end

		moves
	end

	def attacking(board) 
		# Pawn always attacks the diagonals, even if not valid
		i,j = locate_self(board)
		attacking = []

		if on_board(next_row(j,1))
			if on_board(i - 1)
				attacking << [i - 1, next_row(j,1)]
			end
			if on_board(i + 1)
				attacking << [i + 1, next_row(j,1)]
			end
		end

		attacking
	end
end

class Blank
	attr_accessor :symbol

	def initialize
		@symbol = "_"
	end

	def is_blank
		true
	end
end

