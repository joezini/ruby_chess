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
end

class Board
	attr_accessor :placements

	def initialize
		@placements = Array.new(8) {Array.new(8, nil)}
		@layout = %Q(  __ __ __ __ __ __ __ __
8|__|__|__|__|__|__|__|__|
7|__|__|__|__|__|__|__|__|
6|__|__|__|__|__|__|__|__|
5|__|__|__|__|__|__|__|__|
4|__|__|__|__|__|__|__|__|
3|__|__|__|__|__|__|__|__|
2|__|__|__|__|__|__|__|__|
1|__|__|__|__|__|__|__|__|
   a  b  c  d  e  f  g  h)
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
			if team == "w"
				row = 0
			elsif team == "b"
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
			if team == "w"
				row = 1
			elsif team == "b"
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

		set_major_row("w")
		set_pawn_row("w")
		set_blank_rows
		set_pawn_row("b")
		set_major_row("b")
	end
end

class King
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "K"
		else
			@symbol = "k"
		end
	end

	def is_blank
		false
	end
end

class Queen
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "Q"
		else
			@symbol = "q"
		end
	end

	def is_blank
		false
	end
end

class Bishop
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "B"
		else
			@symbol = "b"
		end
	end

	def is_blank
		false
	end
end

class Knight
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "N"
		else
			@symbol = "n"
		end
	end

	def is_blank
		false
	end
end

class Rook
	include Locate
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
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

		def on_board(i, j)
			if i >= 0 && i <= 7 && j >= 0 && j <= 7
				true
			else
				false
			end
		end

		def next_square(x, y, dir)
			case dir
			when "up" [x, y + 1]
			when "down" [x, y - 1]
			when "left" [x - 1, y]
			when "right" [x + 1, y]
			end
		end

		def check_line_from(x, y, dir, board)
			blocked = false
			moves = []
			until blocked || !on_board(x, y) do
				puts "Current coords #{x}, #{y}"
				next_x, next_y = next_square(x, y, dir)
				puts "next coords #{next_x}, #{next_y}"
				if on_board(next_x, next_y) && board.placements[next_x][next_y].is_blank
					moves << [next_x, next_y]
					x,y = next_x, next_y
				elsif on_board(next_x,next_y) && !board.placements[next_x][next_y].is_blank && board.placements[next_x][next_y].team != @team
					moves << [next_x, next_y]
					blocked = true
				end
			end
			moves
		end

		moves += check_line_from(i, j, "up", board)
		moves += check_line_from(i, j, "down", board)
		moves += check_line_from(i, j, "left", board)
		moves += check_line_from(i, j, "right", board)

		moves
	end
end

class Pawn
	include Locate
	attr_accessor :team, :symbol, :has_moved

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "P"
		else
			@symbol = "p"
		end
		@has_moved = false
	end

	def is_blank
		false
	end

	def valid_moves(board)
		i,j = locate_self(board)
		moves = []
		blocked = false

		def next_row(j, no_rows)
			if @team == "w"
				j + no_rows
			else
				j - no_rows
			end
		end

		def on_board(row)
			if row >= 0 && row <= 7
				true
			else
				false
			end
		end

		if on_board(next_row(j,1)) && board.placements[i][next_row(j,1)].is_blank
			moves << [i, next_row(j,1)]
		else
			blocked = true
		end
		if !@has_moved && board.placements[i][next_row(j,2)].is_blank && !blocked
			moves << [i, next_row(j,2)]
		end
		if on_board(next_row(j,1)) && !board.placements[i - 1][next_row(j,1)].is_blank && board.placements[i - 1][next_row(j,1)].team != @team
			moves << [i - 1, next_row(j,1)]
		end
		if on_board(next_row(j,1)) && !board.placements[i + 1][next_row(j,1)].is_blank && board.placements[i + 1][next_row(j,1)].team != @team
			moves << [i + 1, next_row(j,1)]
		end

		moves
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

