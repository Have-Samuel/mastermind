# Module containing possibe code values and player input/validtion
module Masmind
  RANGE = [1, 2, 3, 4, 5, 6]

  def player_input
    puts 'Please enter a number between 1 and 6 in a row on one line:'
    input = gets.chomp
    input.ascii = input.each_byte.to_a

    until input.length == 4 && input.ascii.all? { |num| num >= 49 && num <= 54 }
      puts 'Make sure you have entered a valid code!'
      input = gets.chomp
      input.ascii = input.each_byte.to_a
    end
    @player_input_code = input.split
  end
end

