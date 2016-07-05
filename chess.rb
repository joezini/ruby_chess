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
		7.downto(0) do |i|
			output << (i+1).to_s + "|"
			0.upto(7) do |j|
				symbol = "_"
				if @placements[i][j] != nil
					symbol = @placements[i][j].symbol
				end
				output << symbol + "_|"
			end
			output << "\n"
		end
		output << "   a  b  c  d  e  f  g  h"

		output
	end

	def set_starting_positions
		@placements[0][0] = Rook.new("w")
		@placements[0][1] = Knight.new("w")
		@placements[0][2] = Bishop.new("w")
		@placements[0][3] = Queen.new("w")
		@placements[0][4] = King.new("w")
		@placements[0][5] = Bishop.new("w")
		@placements[0][6] = Knight.new("w")
		@placements[0][7] = Rook.new("w")
		(0..7).each do |j| 
			@placements[1][j] = Pawn.new("w")
		end
		(2..5).each do |i|
			(0..7).each do |j|
				@placements[i][j] = nil
			end
		end
		(0..7).each do |j| 
			@placements[6][j] = Pawn.new("b")
		end
		@placements[7][0] = Rook.new("b")
		@placements[7][1] = Knight.new("b")
		@placements[7][2] = Bishop.new("b")
		@placements[7][3] = Queen.new("b")
		@placements[7][4] = King.new("b")
		@placements[7][5] = Bishop.new("b")
		@placements[7][6] = Knight.new("b")
		@placements[7][7] = Rook.new("b")
	end
end

class King
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "K"
		else
			@symbol = "k"
		end
	end
end

class Queen
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "Q"
		else
			@symbol = "q"
		end
	end
end

class Bishop
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "B"
		else
			@symbol = "b"
		end
	end
end

class Knight
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "N"
		else
			@symbol = "n"
		end
	end
end

class Rook
	attr_accessor :team, :symbol

	def initialize(team)
		@team = team
		if team == "w"
			@symbol = "R"
		else
			@symbol = "r"
		end
	end
end

class Pawn
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

	def valid_moves(pos, board)
		i = pos[0]
		j = pos[1]
		moves = []
		if @team == "w"
			# move up the board
			moves << [i, j + 1] if j < 7
			moves << [i, j + 2] if !@has_moved #this should only be poss if the prev sq wasn't occupied...
		else
			# move down the board
			moves << [i, j - 1] if j > 0
			moves << [i, j - 2] if !@has_moved
		end
		moves
	end
end