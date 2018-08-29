require 'pstore'

class Game 
  attr_reader :wrong_letters, :tries, :secret_word, :correct_guess, :dictionary
  def initialize(load=false)
  	@wrong_letters = Array.new
  	@tries = 10
  	@secret_word = ""
  	@correct_guess = ""
  	@dictionary = []
  	if load
  		load_game(load)
  	end
  end

  def save(file_name)
  	store = PStore.new(file_name)
  	store.transaction do
  	  store[:game] ||= self
  	end
  end

  def load_game(file_name)
  	store = PStore.new(file_name)
  	tmp_game =[]
  	store.transaction do
  	  tmp_game = store[:game]
  	end
  	tmp_game.inspect
  	@wrong_letters = tmp_game.wrong_letters
  	@correct_guess = tmp_game.correct_guess
  	@secret_word = tmp_game.secret_word
  	@tries = tmp_game.tries
  	@dictionary = tmp_game.dictionary
  end

  def load_dictionary(file_name)
  	@dictionary = File.open(file_name){|f| f.readlines}
  end
	
  def generate_secret_word
  	len = @dictionary.length
  	@secret_word = @dictionary[rand(0..len)]
  	sec_len = @secret_word.length
  	puts "secret_word #{@secret_word}"
  	while (sec_len < 5 || sec_len >12)
  	  @secret_word = @dictionary[rand(0..len)]
  	  sec_len = @secret_word.length
  	end
  	@secret_word = @secret_word.chomp
    @correct_guess = "".rjust(@secret_word.length,"-")
    @secret_word.downcase!
    puts "secret_word #{@secret_word}"
  end

  def get_user_guess
  	puts "Enter Your Letter guess :"
  	letter = gets.chomp
  	letter.downcase!
  	while (wrong_letters.include?(letter) || correct_guess.include?(letter) )
  	  puts "You've choosen this before... Choose another letter"
  	  letter = gets.chomp
  	  letter.downcase!
  	end
  	letter
  end

  def letter_exist?(letter)
    if @secret_word.include?letter
      @secret_word.each_char.with_index do |l,i|
      	if letter == l
      	  @correct_guess[i] = l
      	end
      end
      true
    else
      @wrong_letters << letter
      false
    end

  end

  def display_correct_char
  	puts @correct_guess.center(50)
  end

  def display_wrong_char
  	print "Wrong characters : "
  	print @wrong_letters.join(", ")
  	puts ""
  end

  def game_over?
   (@tries == 0 || @correct_guess == @secret_word)
  end
  
  def won?
   @correct_guess == @secret_word
  end

  def result(letter)
    if letter_exist?(letter)
      puts "Good guess !"
    else
  	  puts "Wrong guess !"
  	  @tries-=1
    end
    puts "#{@tries} Tries Left !" if @tries > 0
  end

  def save_game?
  	puts "Do you want to save game? y for yes n for continue"
  	choice = gets.chomp
  	if choice == "y"
  	  puts "Enter File name "
  	  file_name = gets.chomp
  	  self.save(file_name)
  	  true
  	else
  	  false
  	end
  end

  def play
    while !game_over?
      return if save_game?
	  letter = get_user_guess
	  result(letter)
	  display_correct_char
	  display_wrong_char
	end
	if won?
	 puts "You Won !".center(70, "*")
	else
	  puts "Game Over You Lost ! ".center(70,"*")
	end
	puts "Your guess :"
	display_correct_char
	puts "Correct Word :"
	puts @secret_word.center(50)
  end
end

def get_checkpoints(dir_path)
  str = "#{dir_path}/*"
  Dir.glob(str)
end


def hangman
	puts "0 for New Game, 1 for Load Game "
	choice = gets.chomp.to_i
	if choice == 0
	  game = Game.new
	  game.load_dictionary("5desk.txt")
	  game.generate_secret_word
	else
	  file_names = []
	  puts "Enter Directory Path: "
	  dir_name = gets.chomp
	  file_names = get_checkpoints(dir_name)
	  
	  if file_names.empty?
	    puts "No Checkpoints found !"
	    return
	  else
	    puts "Current Checkpoints: "
	    puts file_names.join(", ")
	    puts "Enter choosen checkpoint name:"
	    checkpoint_name = gets.chomp
	    game =Game.new(checkpoint_name)
	    puts "checkpoint Loaded !".center(70,"*")
	  end
	end
	game.play
end