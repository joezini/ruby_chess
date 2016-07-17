require 'yaml'

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
		# This also works for capturing enemy pieces
	 	if self.valid_moves(board).include?([x, y])
	 		current_x, current_y = self.locate_self(board)
 			board.placements[x][y] = self
 			board.placements[current_x][current_y] = Blank.new
 			self.has_moved = true
 			self.last_move_turn = board.turn
 			return true
	 	else
	 		return false
	 	end
	end

	def under_attack?(board)
		x, y = locate_self(board)
		attacked_squares = board.attacking_team(self.team)
		attacked_squares.include?([x, y])
	end

	def defended?(board)
		x, y = locate_self(board)
		other_team = case self.team
		when :white
			:black
		else
			:white
		end
		defended_squares = board.attacking_team(other_team)
		defended_squares.include?([x, y])
	end
end

class Board
	attr_accessor :placements, :turn

	def initialize
		@placements = Array.new(8) {Array.new(8, nil)}
		@turn = 1
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

	def attacking_king(team)
		kx, ky = find_king(team)
		attackers = []
		@placements.each do |col|
			col.each do |square|
				if !square.is_blank && square.team != team && square.class != King
					if square.valid_moves(self).include?([kx, ky])
						attackers << square
					end
				end
			end
		end
		attackers
	end

	def find_king(team)
		(0..7).each do |i|
			(0..7).each do |j|
				if @placements[i][j].class == King && @placements[i][j].team == team
					return [i, j]
				end
			end
		end
	end

	def in_check(team)
		kx, ky = find_king(team)
		attacking_team(team).include?([kx, ky])
	end

	def in_checkmate(team)
		kx, ky = find_king(team)
		king = placements[kx][ky]
		kings_moves = king.valid_moves(self)
		if kings_moves.size == 0
			attackers = attacking_king(team)
			safe_attackers = attackers.select {|a| !a.under_attack?(self) || a.defended?(self)}
			number_of_safe_attackers = safe_attackers.size
			number_of_unsafe_attackers = attackers.size - number_of_safe_attackers

			if number_of_safe_attackers >= 1 || number_of_unsafe_attackers >= 2
				return true
			else
				return false
			end
		end
	end
end

class King
	include Locate
	attr_accessor :team, :symbol, :has_moved, :last_move_turn

	def initialize(team)
		@team = team
		@has_moved = false
		@last_move_turn = 0
		if team == :white
			@symbol = "K"
		else
			@symbol = "k"
		end
	end

	def is_blank
		false
	end

	def valid_moves(board)
		@board = board
		i,j = locate_self(board)
		enemy_team = case @team
		when :white
			:black
		when :black
			:white
		end
		ex,ey = @board.find_king(enemy_team)
		moves = []
		attacked = @board.attacking_team(@team)

		def attacked_by_enemy_king?(x, y, enemy_x, enemy_y)
			if (enemy_x - x).abs <= 1 && (enemy_y - y).abs <= 1
				return true
			else
				return false
			end
		end

		def check_direction(x, y, dir, attacked, enemy_king_x, enemy_king_y)
			move = []
			next_x, next_y = next_square(x, y, dir)

			if on_board(next_x, next_y) && !attacked.include?([next_x,next_y]) && !attacked_by_enemy_king?(next_x,next_y,enemy_king_x,enemy_king_y)
				if @board.placements[next_x][next_y].is_blank || @board.placements[next_x][next_y].team != @team
					move << [next_x, next_y]
				end
			end
	
			move
		end

		def check_attacked(squares)
			if @board.attacking_team(@team).any? {|sq| squares.include?(sq)}
				true
			else
				false
			end
		end


		moves += check_direction(i, j, "up", attacked, ex, ey)
		moves += check_direction(i, j, "ne", attacked, ex, ey)
		moves += check_direction(i, j, "right", attacked, ex, ey)
		moves += check_direction(i, j, "se", attacked, ex, ey)
		moves += check_direction(i, j, "down", attacked, ex, ey)
		moves += check_direction(i, j, "sw", attacked, ex, ey)
		moves += check_direction(i, j, "left", attacked, ex, ey)
		moves += check_direction(i, j, "nw", attacked, ex, ey)

		# castling
		if !@has_moved && @board.placements[0][0].class == Rook && !@board.placements[0][0].has_moved 
			if @board.placements[1][0].is_blank && @board.placements[2][0].is_blank && @board.placements[3][0].is_blank 	
				if !check_attacked([[2, 0], [3, 0], [4, 0]])			
					moves << [2, 0]
				end
			end
		end

		if !@has_moved && @board.placements[0][7].class == Rook && !@board.placements[0][7].has_moved 
			if @board.placements[5][0].is_blank && @board.placements[6][0].is_blank	
				if !check_attacked([[4, 0], [5, 0], [6, 0]])
					moves << [6, 0]
				end
			end
		end		

		moves
	end

	def attacking(board)
		valid_moves(board)
	end

	def move(x, y, board)
		# Special extra logic for castling
	 	if self.valid_moves(board).include?([x, y])
	 		current_x, current_y = self.locate_self(board)
	 		if (current_x - x).abs == 2
	 			# must be castling
	 			if x == 2
	 				left_rook = board.placements[0][0]
	 				board.placements[3][0] = left_rook
	 				board.placements[0][0] = Blank.new
	 				left_rook.has_moved = true
	 				left_rook.last_move_turn = board.turn
	 			elsif x == 6
	 				right_rook = board.placements[7][0]
	 				board.placements[5][0] = right_rook
	 				board.placements[7][0] = Blank.new
	 				right_rook.has_moved = true
	 				right_rook.last_move_turn = board.turn
	 			end
	 		end
 			board.placements[x][y] = self
 			board.placements[current_x][current_y] = Blank.new
 			self.has_moved = true
 			self.last_move_turn = board.turn
 			return true
	 	else
	 		return false
	 	end
	end
end

class Queen
	include Locate
	attr_accessor :team, :symbol, :has_moved, :last_move_turn

	def initialize(team)
		@team = team
		@has_moved = false
		@last_move_turn = 0
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
	attr_accessor :team, :symbol, :has_moved, :last_move_turn

	def initialize(team)
		@team = team
		@has_moved = false
		@last_move_turn = 0
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
	attr_accessor :team, :symbol, :has_moved, :last_move_turn

	def initialize(team)
		@team = team
		@has_moved = false
		@last_move_turn = 0
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
	attr_accessor :team, :symbol, :has_moved, :last_move_turn

	def initialize(team)
		@team = team
		@has_moved = false
		@last_move_turn = 0
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
	attr_accessor :team, :symbol, :has_moved, :has_moved, :last_move_turn

	def initialize(team)
		@team = team
		@has_moved = false
		@last_move_turn = 0
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
		# Can move diagonally if there's a piece to capture
		# or an opponent pawn just moved 2 squares (en passant)
		if on_board(next_row(j,1))
			if on_board(i - 1)
				diagonal_capture = !board.placements[i - 1][next_row(j,1)].is_blank && board.placements[i - 1][next_row(j,1)].team != @team
				en_passant = !board.placements[i - 1][j].is_blank && board.placements[i - 1][j].team != @team && board.placements[i - 1][j].class == Pawn && board.placements[i - 1][j].last_move_turn == board.turn - 1
				if diagonal_capture || en_passant
					moves << [i - 1, next_row(j,1)]
				end
			end
			if on_board(i + 1)
				diagonal_capture = !board.placements[i + 1][next_row(j,1)].is_blank && board.placements[i + 1][next_row(j,1)].team != @team
				en_passant = !board.placements[i + 1][j].is_blank && board.placements[i + 1][j].team != @team && board.placements[i + 1][j].class == Pawn && board.placements[i + 1][j].last_move_turn == board.turn - 1
				if diagonal_capture || en_passant
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

	def move(x, y, board)
		# This also works for capturing enemy pieces
	 	if self.valid_moves(board).include?([x, y])
	 		current_x, current_y = self.locate_self(board)
	 		# en-passant
	 		if board.placements[x][y].is_blank && x != current_x
	 			board.placements[x][current_y] = Blank.new
	 		end
 			board.placements[x][y] = self
 			board.placements[current_x][current_y] = Blank.new
 			self.has_moved = true
 			self.last_move_turn = board.turn
 			return true
	 	else
	 		return false
	 	end
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

class Game
	attr_accessor :game_over

	def initialize
		@board = Board.new
		@board.set_starting_positions
		@game_over = false
		@save_folder = "saves"
	end

	def play
		@letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
		@numbers = ['1', '2', '3', '4', '5', '6', '7', '8']

		def validate_square(entry)
			if entry.length == 2
				if @letters.include?(entry[0]) && @numbers.include?(entry[1])
					true
				else
					false
				end
			else
				false
			end
		end

		def validate_piece(entry, player)
			x = @letters.find_index(entry[0])
			y = @numbers.find_index(entry[1])
			if !@board.placements[x][y].is_blank
				if @board.placements[x][y].team == player
					[x, y]
				else
					false
				end
			else
				false
			end
		end

		def save_game
			save_data = YAML::dump(@board)
			Dir.mkdir(@save_folder) unless File.directory?(@save_folder)
			timestamp = Time.now.strftime("%d-%m-%Y_%H-%M-%S")
			save_file = File.new(@save_folder + "/" + timestamp, "w")
			save_file.puts save_data
			save_file.close
			puts "Game saved as " + timestamp
		end

		def open_game
			files = Dir.glob(@save_folder + "/*")
			files.each_with_index do |f, i|
				puts "#{i+1}: #{f}"
			end
			valid_file = false
			until valid_file
				puts "Please select a save file:"
				selection = gets.chomp
				if selection.to_i > 0 && selection.to_i <= files.size
					valid_file = true
				end
			end
			open_file = files[selection.to_i - 1]
			save_data_raw = ''
			File.open(open_file).each do |line|
				save_data_raw << line
			end
			save_data = YAML::load(save_data_raw) 
			puts save_data
			@board = save_data
			puts "File #{open_file} opened!"
			puts @board.as_string
		end

		def quit_game
			puts "Quit: are you sure? (y/n)"
			confirm = gets.chomp
			if confirm == "y"
				return true
			else
				return false
			end
		end

		def choose_action(player)
			valid = false
			piece = ""
			until valid do
				puts "It's #{player}'s turn, please enter a piece to move (e.g. d4)"
				puts "or enter 'q' to quit, 's' to save or 'o' to open"
				piece = gets.chomp
				if validate_square(piece) && validate_piece(piece, player)
					valid = true
					return validate_piece(piece, player)
				elsif piece == "q"
					if quit_game
						valid = true
						@game_over = true
					end
				elsif piece == "s"
					save_game
				elsif piece == "o"
					open_game
				end
			end
		end

		def promote(piece, x, y)
			promoted = false
			until promoted do
				puts "Congrats! What do you want to promote the pawn to? (q/b/n/r)"
				new_rank = gets.chomp
				case new_rank
				when "q"
					@board.placements[dx][dy] = Queen.new(piece.team)
					promoted = true
				when "b"
					@board.placements[dx][dy] = Bishop.new(piece.team)
					promoted = true
				when "n"
					@board.placements[dx][dy] = Knight.new(piece.team)
					promoted = true
				when "r"
					@board.placements[dx][dy] = Rook.new(piece.team)
					promoted = true
				end
			end
		end

		def make_move(piece)
			valid = false
			until valid do 
				puts "#{piece.class} - enter destination square"
				puts "or type 'x' to select a different piece:"
				dest = gets.chomp
				if validate_square(dest)
					dx = @letters.find_index(dest[0])
					dy = @numbers.find_index(dest[1])
					if piece.move(dx, dy, @board)
						# Check if there's a pawn to promote
						if piece.class == Pawn && (dy == 0 || dy == 7)
							promote(piece, dx, dy)
						end
						valid = true
					end
				else
					if dest == 'x'
						x, y = choose_action(piece.team)
						piece = @board.placements[x][y]
					end
				end
			end
		end

		puts "Welcome to my chess game!"
		puts @board.as_string
		player = :white
		opponent = :black
		until @game_over do
			x, y = choose_action(player)
			if !@game_over
				piece = @board.placements[x][y]
				make_move(piece)
				puts @board.as_string
				if @board.in_checkmate(opponent)
					puts "Checkmate! #{player} wins!"
					@game_over = true
				elsif @board.in_check(opponent)
					puts "Check!"
				end
				if player == :white
					player, opponent = :black, :white
				else
					player, opponent = :white, :black
				end
				@board.turn += 1
			end
		end
	end
end

game = Game.new
game.play