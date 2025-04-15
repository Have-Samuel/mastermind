# Module containing possibe code values and player input/validtion
module Masmind
  RANGE = [1, 2, 3, 4, 5, 6]

  def player_input
    puts 'Please enter a number between 1 and 6 in a row on one line:'
    input = gets.chomp # chomp removes the newline character and returns the string which is assigned to input
    input_ascii = input.each_byte.to_a
    # With the ASCII values of the input, check if the input is valid. The ascii start from 49 to 54 meaning 1 to 6 for this case, eg '1234' => [49, 50, 51, 52] and '3452' => [51, 52, 53, 50]
    until input.length == 4 && input_ascii.all? { |num| num >= 49 && num <= 54 }
      puts 'Make sure you have entered a valid code!'
      input = gets.chomp
      input_ascii = input.each_byte.to_a
    end
    # Once you get the code, we call the split method to convert it into an array of strings, eg '1234' => ['1', '2', '3', '4']
    @player_input_code = input.split
  end
end

# Game class allows for the continous replay function, instantiates Board class
class Game
  attr_accessor :board

  def initialize
    @board = Board.new
  end

  def play_again
    puts 'Enter Y to play again or N to quit:'
    answer = gets.chomp
    case answer
    when 'y', 'Y'
      # If the answer is yes, then it will whip out the old game creating a new board
      @board = Board.new
      @board.decide_play_method
      play_again
    else
      # If the answer is no or anything else, then it will exit the game
      puts 'Thanks for playing!'
    end
  end
end

# Board class instantiates PlayerMaker and playerBreaker classes
# and has methods for setting instance variables, evaluating guesses, winners and executing the game

class Board
  include Masmind
  attr_accessor :maker_board, :turn_count, :breaker

  def initialize
    @maker_board = []
    @breaker_board = []
    @winner = false
    @match = 0
    @partial = 0
    @player_breaker = PlayerBreaker.new
    @player_maker = PlayerMaker.new
    puts 'Enter 1 to be the code breaker or 2 to be the code maker:'
    @play_method = gets.chomp
    @turn_count = 1
  end

  # if player is breaker, set instance variables and call player_input method
  def player_is_breaker
    @breaker_board = @player_breaker.player_input_code
  end

  # if player is maker, set instance variables and call player_input method
  def player_is_maker
    @maker_board = @player_maker.player_input_code
    @breaker_board = @player_maker.ai_input_code
  end

  # Computer generated code
  def computer_maker
    i = 1
    while i <= 4
      val = Masmind::RANGE.sample
      @maker_board << val
      i += 1
    end
  end

  # Check if there is a correct code guess
  def check_winner
    if @maker_board == @breaker_board
      @turn_count = 13
      @winner = true
    end
  end

  # Check for any matches or partials
  def check_match_partial
    @match = 0
    @partial = 0
    @maker_board.each_with_index do |num, idx|
      @breaker_board.each_with_index do |num2, idx2|
        if num == num2 && idx == idx2
          @match += 1
        elsif num == num2 && idx != idx2
          @partial += 1
        end
      end
    end

    puts "Match: #{@match}"
    puts "Partial: #{@partial}"
    puts "\r\n"
  end

  # Determine if there is a winner
  def result
    case @player_choice
    when '1'
      if @winner == true
        puts 'Congratulations, you solved it!'
      else
        puts "The code was #{@maker_board.join}. Better luck next time!"
      end
    else
      if @winner == true
        puts 'THe machine figured out your code!'
      else
        puts 'You beat the machine!'
      end
    end
  end

  # Determine which play method to execute
  def decide_play_method
    case @player_choice
    when '1'
      play_player_breaker
    else
      play_player_maker
    end
  end

  # Execute if player is code breaker
  def play_player_breaker
    computer_maker
    until @turn_count >= 13
      puts "Turn: #{@turn_count}"
      @player_breaker.player_input
      player_is_breaker
      check_winner
      check_match_partial
      @turn_count += 1
    end
    result
  end

  # Execute if player is code maker
  def play_player_maker
    @player_maker.player_input
    @player_maker.first_guess
    check_match_partial
    @turn_count += 1
    until @turn_count >= 13
      puts "Turn: #{@turn_count}"
      @player_maker.solve
      player_is_maker
      check_winner
      check_match_partial
      @turn_count += 1
      sleep(0.25)
    end
    result
  end
end

# Player is the code breaker
class PlayerBreaker
  include Masmind
  attr_accessor :player_input_code

  def initialize
    @player_input_code = []
  end
end

# Player is the code maker
class PlayerMaker
  include Masmind
  attr_accessor :player_input_code, :ai_input_code

  def initialize
    @player_input_code = []
    @ai_input_code = []
  end

  # First guess - all four values are the same
  def first_guess
    value = Masmind::RANGE.sample
    i = 1
    while i <= 4
      @ai_input_code << value
      i += 1
    end
    puts "Computer guessed: #{@ai_input_code}"
  end

  # Keep matches and picks a new random number for non-matches
  def solve
    new_guess = []
    i = 0
    while i <= 3
      new_guess << if @player_input_code[i] == @ai_input_code[i]
                     @player_input_code[i]
                   else
                     Masmind::RANGE.sample
                   end
      i += 1
    end
    @ai_input_code = new_guess
    puts "Computer guessed: #{@ai_input_code}"
  end
end

# Instructions for the game
puts 'Welcome to Mastermind: a code breaking game between you and the computer!'
puts 'You will either be the code maker or the code breaker.'
puts 'The code maker will create a code of four numbers between 1 and 6.'
puts 'The code breaker will try to guess the code in 12 turns, receiving feedback on each guess.'
puts "The feedback will include the number of matches and partial matches, match = 'correct value and position:' partial = 'correct value, wrong position'"
puts 'The game will end when the code breaker guesses the code or runs out of turns.'
puts 'Good luck!'
puts "\r\n"

game = Game.new
game.board.decide_play_method
game.play_again
