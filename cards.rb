SUITS = [
    :hearts,
    :diamonds,
    :spades,
    :clubs
]

CARDS = [
    :two,
    :three,
    :four,
    :five,
    :six,
    :seven,
    :eight,
    :nine,
    :ten,
    :jack,
    :queen,
    :king,
    :ace
]

class Card
    attr_reader :card, :suit

    def initialize suit, card
        # initialize a card with a suit and card value
        # check and raise exception with invalid init values
        unless SUITS.include? suit
            raise "suit param must be valid symbol"
        end
        @suit = suit
        unless CARDS.include? card
            raise "card param must be valid symbol"
        end
        @card = card
    end

    def value
        card_value = {
            two:    2,
            three:  3,
            four:   4,
            five:   5,
            six:    6,
            seven:  7,
            eight:  8,
            nine:   9,
            ten:   10,
            jack:  10,
            queen: 10,
            king:  10,
            # the ace value'd at 1 is part of scoring logic
            ace:    1
        }
        card_value[@card]
    end

    def display
        # return a unicode string, for output to terminal
        # 3 char wide, card as single char (except 10), icon for suit
        card_strings = {
            two:   " 2",
            three: " 3",
            four:  " 4",
            five:  " 5",
            six:   " 6",
            seven: " 7",
            eight: " 8",
            nine:  " 9",
            ten:   "10",
            jack:  " J",
            queen: " Q",
            king:  " K",
            ace:   " A"
        }
        suit_icons = {
            hearts:   "\u2665",
            diamonds: "\u2666",
            spades:   "\u2660",
            clubs:    "\u2663"
        }
        "#{card_strings[@card]}#{suit_icons[@suit]}"
    end

end


class Deck
    attr_reader :cards

    def initialize
        # initialize @cards, an array of Card in a deck (52)
        @cards = []
        SUITS.each do | suit |
            CARDS.each do | card |
                @cards << Card.new(suit, card)
            end
        end
    end

    def draw
        # pop a card of the internal array
        @cards.pop
    end

    def shuffle
        # shuffle the internal @cards array
        @cards = @cards.sort_by { rand }
    end

end


class Shoe

    def initialize decks
        # initialize @cards, and array of cards in shoe, with 'decks' # of decks
        @cards = []
        (1..decks).each do | n |
            d = Deck.new
            d.cards.each do | c |
                @cards << c
            end
        end
        # shuffle the decks together
        @cards = @cards.sort_by { rand }
    end

    def remaining
        @cards.count
    end

    def draw
        # pop a card of the internal array
        @cards.pop
    end

end


class Hand
    attr_reader :cards

    def initialize
        @cards = []
        @doubled = false
        @surrender = false
    end

    def count
        return @cards.count
    end

    def add(card)
        # add a card to the hand
        unless card.is_a? Card
            raise "can only add Card to Hand"
        end
        @cards << card
    end

    def has_ace?
        # check if hand contains an ace
        @cards.each do | card |
            if card.card == :ace
                return true
            end
        end
        false
    end

    def has_split?
        return true if @cards.count == 2 and @cards[0].card == @cards[1].card
        false
    end

    def has_blackjack?
        if @cards.count == 2 and has_ace?
            k = [ :ten, :jack, :queen, :king ]
            if k.include?(@cards[0].card) or k.include?(@cards[1].card)
                return true
            end
        end
        false
    end

    def doubled?
        return @doubled
    end

    def doubled!
        @doubled = true
    end

    def surrender!
        @surrender = true
    end

    def surrender?
        return @surrender
    end

    def upcard
        if @cards.count > 1
            @cards[1].value
        end
    end

    def score
        # if hand has only 2 cards, check for blackjack
        if @cards.count == 2 and has_ace?
            k = [ :ten, :jack, :queen, :king ]
            if k.include?(@cards[0].card) or k.include?(@cards[1].card)
                return [ 'blackjack', 21 ]
            end
        end
        # if no special case exists, prepare to return standard scoring
        descript, score = 'hard', 0
        @cards.each do |c|
            score += c.value
        end
        # if hand contains any aces, determine soft/hard scores
        if self.has_ace?
            if (score + 10) <= 21
                descript = 'soft'
                score += 10
            end
        end
        # return score of hand, in form of 'descriptor', 'score'
        [ descript, score ]
    end

    def bust?
        # 'true' to 'stand' when a hand is 'bust'
        return true if score[1] > 21
        # otherwise, proceed in logic to hit
        false
    end

    def stand?
        # stand if hand is equal or greater to 17
        return true if score[1] >= 17
        # otherwise, hit
        false
    end

end
