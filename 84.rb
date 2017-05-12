#!/usr/bin/ruby
# Project Euler 84

# https://projecteuler.net/problem=84

# This is really a 'big' amount of text, but it's the Monopoly problem
#   which I think is a ton of fun.

# handles the rules for building a card pack
# card pack can take multiple players taking the cards
# it's an arbitrary design constraint, but, whatever!
class CardPack
  def initialize
    @cards = (1..16).to_a.shuffle
  end

  def take_card(player)
    card = @cards[0]
    move_card_to_bottom
    send("card#{card}", player)
  end

  def respond_to_missing?(method, include_private = false)
    if method.to_s =~ /card/
      true
    else
      super
    end
  end

  private

  def move_card_to_bottom
    @cards = @cards.rotate # I love .rotate
  end

  def method_missing(method, *args)
    return if method.to_s =~ /card/
    super
  end
end

# Specific for community chest, uses CardPack to hand the core concepts of a
# deck. Shuffling, taking a card, and moving the card to the bottom.
# The card methods themselves take player so that you aren't tightly
# binding to a specific @player class insomuch as something that 'can go to go' 
# or 'can go to jail'.
class CommunityChestCardPack < CardPack
  def card1(player)
    player.go_to_go
  end

  def card2(player)
    player.go_to_jail
  end
end

# Specific for chance, like community chest above.
class ChanceCardPack < CardPack
  def card1(player)
    player.go_to_go
  end

  def card2(player)
    player.go_to_jail
  end

  def card3(player)
    player.position = 11
  end

  def card4(player)
    player.position = 24
  end

  def card5(player)
    player.position = 39
  end

  def card6(player)
    player.position = 5
  end

  # Go to next Railroad. I implemented this in a few different ways. This was
  # clearly the most simple, but I created a generic method that handled this
  # and the utility card, by passing an array to the method, and then adding
  # the position to the array, reverse sorting it, picking the index - 1 of the
  # array... ah, I'll just rewrite it but not reference it.
  def card7(player)
    player.position = 15 if player.position == 7
    player.position = 25 if player.position == 22
    player.position = 5 if player.position == 36
  end
  # there's 2 of these cards in a monopoly chance deck
  alias card8 card7

  # @deprecated
  def go_to_next_railroad_card(player)
    player.position = go_to_next([5, 15, 25, 35], player.position)
  end

  # This was a little magic to me. Because if I didn't reverse it, you'd not
  # be able to go past the end of the array. Ary[4] would be nil, but because
  # ruby loops around back (to make it easy to get the end of an array),
  # you're able to utilize it for positive gain here.
  # @deprecated
  def go_to_next(base_ary, position)
    ary = (base_ary + [position]).sort.reverse
    idx = ary.index(position)
    base_ary.reverse[idx]
  end

  # Utility
  def card9(player)
    player.position = player.position == 22 ? 28 : 12
  end

  # this has to handle landing on spot 36 and taking a community chest card
  def card10(player)
    player.position -= 3
  end
end

# DICE CLASS
class Dice
  attr_reader :movement, :dice1, :dice2
  def initialize(dice_size = 6)
    @dice_size ||= dice_size
    @dice_ary = (1..@dice_size).to_a
  end

  def doubles
    @dice1 == @dice2
  end

  def roll
    @dice1 = @dice_ary.sample
    @dice2 = @dice_ary.sample
    @movement = @dice1 + @dice2
  end
end

# Where the player is! I could have built Player as part of the board, but
# for this purpose, this  way worked better (because we're not keeping the
# state of multiple players, and we're looking at how the board itself
# works)
# The accessors exist in order to read/write the position of the class
# as we pass the class to other things. We're exposing as little state
# of the player as possible in order to get the player to change.
class Player
  attr_accessor :board, :position
  attr_reader :number_of_moves, :number_of_rolls
  def initialize
    @board = Board.new(self)
    @dice = Dice.new
    @position = 0
    @number_of_doubles = 0
    @number_of_moves = 0
    @number_of_rolls = Hash[(2..12).to_a.map { |x| [x, 0] }]
  end

  def move
    roll = @dice.roll
    @position += roll
    @number_of_rolls[roll] += 1
    @dice.doubles ? @number_of_doubles += 1 : @number_of_doubles = 0
    go_to_jail if @number_of_doubles == 3
    @board.action
    @number_of_moves += 1
  end

  def go_to_jail
    @number_of_doubles = 0
    self.position = 10
  end

  def go_to_go
    self.position = 0
  end
end

# Builds the board out to handle the action of what happens when you
# land on a position, it can't handle multiple players (but it could with)
# just a little bit of minor tweaking (namely, change initialize to take player)
# or a new function for setup_player. And then we'd add a turn indicator
# during the action, rotate the turn if in jail or not doubles.
class Board
  attr_reader :rate

  def initialize(player)
    @chance_cards = ChanceCardPack.new
    @community_chest_cards = CommunityChestCardPack.new
    @player = player
    @rate = Hash[(0..39).to_a.map { |x| [x, 0] }]
  end

  def action
    pass_go? # this maybe shouldn't be a ? method, but it feels so right.
    @chance_cards.take_card(@player) if [7, 22, 36].include?(@player.position)
    if [2, 18, 33].include?(@player.position)
      @community_chest_cards.take_card(@player)
    end
    @player.go_to_jail if @player.position == 30
    increment_rate
  end

  private

  def pass_go?
    @player.position = @player.position - 40 if @player.position > 39
  end

  def increment_rate
    @rate[@player.position] += 1
  end
end

LIMIT = 10_000_000
player = Player.new

player.move while player.number_of_moves < LIMIT

p player.number_of_rolls
p player.board.rate.sort_by { |_x, y| y }.reverse.to_h
p player.board.rate.sort_by { |_x, y| y }.reverse.first(3).to_h

# {10=>697661, 15=>358580, 24=>328706}

# or 101524. 15 is clearly understandable as 15 is 5 above 10, and just by
# sheer volume of 5's (why I'm looking @ number of rolls) but I'm totally
# unsure as to why 24. I know why it's 24 when it's 6x2's... because the
# most common place to be is jail & the most common roll is 7.
# So, from square 10 (jail), if you roll twice, you're most likely to get
# to square 24 (Illinois/Trafalgar). But, with 4 sided die, the average is 5
# which'd give you 15, but then you should have a much higher 20 rate.

# Here's the 4 sided die list.

# {10=>696202, 15=>357957, 24=>329158, 16=>323134, 25=>312815, 19=>304097,
#  21=>303926, 20=>300075, 23=>298079, 18=>297921, 5=>290633, 14=>288736,
#  28=>288524, 31=>281801, 0=>278938, 29=>275519, 17=>271459, 26=>264919,
#  32=>259566, 27=>255234, 13=>251073, 39=>248267, 11=>244760, 12=>239378,
#  4=>228945, 34=>221156, 33=>220003, 37=>213182, 8=>211701, 9=>210740,
#  6=>208962, 38=>208129, 3=>202985, 35=>198943, 1=>176463, 2=>167429,
#  22=>113810, 7=>78351, 36=>77030, 30=>0}

# Here's the 6 sided die list (again sorted)

# {10=>623000, 24=>318962, 0=>309955, 19=>309858, 25=>306673, 5=>297990,
#  18=>293646, 15=>290015, 20=>287764, 21=>282903, 28=>279297, 16=>279154,
#  23=>273279, 26=>271066, 11=>270858, 31=>268198, 27=>266661, 39=>263062,
#  32=>261937, 12=>260357, 29=>258001, 17=>256441, 34=>249486, 14=>246643,
#  35=>242773, 13=>238151, 33=>237297, 8=>232604, 4=>231714, 9=>229974,
#  6=>227443, 37=>218086, 38=>217876, 3=>216465, 1=>213299, 2=>190749,
#  22=>103534, 36=>89355, 7=>85474, 30=>0}

# So, there's a few trends here... the larger the die, the less likely
# you'll actually go to jail (chance of doubles reduced), which would
# lower the amount of highest average die roll.
