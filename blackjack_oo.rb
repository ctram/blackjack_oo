
class Player
  attr_accessor :name, :hand

  def initialize name
    self.name = name
    self.hand = Hand.new
  end
end

class Hand
  attr_accessor :cards, :bust

  def initialize
    self.cards = []
    self.bust = false
  end

  def total
    hash_values_to_i = {
      "Ace" =>  11,
      "Two" =>  2,
      "Three" =>  3,
      "Four" =>  4,
      "Five" =>  5,
      "Six" =>  6,
      "Seven" => 7 ,
      "Eight" =>  8,
      "Nine" =>  9,
      "Ten" =>  10,
      "Jack" =>  10,
      "Queen" =>  10,
      "King" =>  10,
    }
    sum = 0
    num_aces = 0
    self.cards.each do |card|
      if card.visible != false
        card.value == "Ace" ? num_aces += 1 : nil
        sum += hash_values_to_i[card.value]
      end
    end

    while sum > 21 and num_aces > 0
      sum = sum - 11 + 1
      num_aces -= 1
    end
    sum

  end

end

class Card
  attr_accessor :suit, :value, :visible

  def initialize suit, value
    self.suit = suit
    self.value = value
    self.visible = true
  end
end

class Deck
  attr_accessor :cards

  def initialize
    suits = %w(Diamonds Spades Clubs Hearts)
    values = %w(Ace Two Three Four Five Six Seven Eight Nine Ten Jack Queen King)

    self.cards = []

    # Creates a deck of 52 cards
    suits.each do |suit|
      values.each do |value|
        self.cards << Card.new(suit, value)
      end
    end
  end
end

class Game
  attr_accessor :user, :dealer, :deck

  def initialize
    self.dealer = Player.new("Dealer")
    self.deck = Deck.new
    self.deck.cards.shuffle
  end

  # Give player another card from the deck, to add to his hand
  def hit player
    player.hand.cards << self.deck.cards.pop
  end

  def display_winner
    puts
    if self.user.hand.bust
      puts "#{self.user.name} busts! Dealer wins!"
    else
      if self.dealer.hand.bust
        puts "Dealer busts! #{self.user.name} wins!"
      else
        if self.user.hand.total > self.dealer.hand.total
          puts "#{self.user.name} wins!"
        elsif self.user.hand.total == self.dealer.hand.total
          puts "#It's a push, no one wins."
        else
          puts "Dealer wins!"
        end
      end
    end
  end

  def display_hands
    system 'clear'
    puts "Dealer's hand:"
    self.dealer.hand.cards.each do |card|
      if card.visible
        print "#{card.value}_#{card.suit}"
        print "  "
      else
        print "Card_hidden_from_user"
      end
    end
    puts
    puts "Total showing: " + self.dealer.hand.total.to_s

    puts
    puts "#{self.user.name}'s hand:"
    self.user.hand.cards.each do |card|
      print "#{card.value}_#{card.suit}"
      print "  "
    end
    puts
    puts "Total: " + self.user.hand.total.to_s
  end

  def run
    puts "Welcome to Blackjack!"
    puts "Please enter your name"
    print ">>"
    name = gets.chomp.capitalize

    begin
      self.user = Player.new(name)
      self.dealer = Player.new("Dealer")

      # Deal initial cards
      hit(self.user)
      hit(self.dealer)
      hit(self.user)
      hit(self.dealer)

      self.dealer.hand.cards[1].visible = false   # Last card is not visible to the user until user stays

      display_hands()

      loop do
        # Until user stays or busts
        acceptable_input = %w(h s)
        input = nil
        until acceptable_input.include? input
          puts "Hit (h) or Stay (s)?"
          print ">>"
          input = gets.chomp.downcase
        end

        case input
        when "h"
          hit(user)
          display_hands()
          self.user.hand.total > 21 ? self.user.hand.bust = true : nil
          self.user.hand.bust ? break : nil
        when "s"
          break
        end
      end

      # Check whether user bust before going onto comp part
      self.user.hand.total > 21 ? self.user.hand.bust = true : nil

      # Dealer's part
      if !self.user.hand.bust
        self.dealer.hand.cards[1].visible = true  # Now show the previously hidden card.
        until self.dealer.hand.total >= 17
          hit(self.dealer)
        end
        display_hands()
      end

      self.dealer.hand.total > 21 ? self.dealer.hand.bust = true : nil

      display_winner()

      puts "Press q to quit. Otherwise press any key to play again."
      print ">>"
      input = gets.chomp.downcase
      input == "q" ? user_wants_quit = true : user_wants_quit = false

    end until user_wants_quit
  end
end
game = Game.new
game.run
