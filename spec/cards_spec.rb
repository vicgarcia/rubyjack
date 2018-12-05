require 'spec_helper'


describe Card do

    describe "#init" do
        it "is initialized with a suit and card" do
            c = Card.new :hearts, :six

            expect(c).to be_an_instance_of Card
            expect(c.suit).to eql :hearts
            expect(c.card).to eql :six
        end
    end

    describe "#value" do
        it "returns values based on the card" do
            s = Card.new :hearts, :six
            a = Card.new :spades, :ace
            k = Card.new :diamonds, :king

            # six is 6
            expect(s.value).to eql 6
            # ace is 1
            expect(a.value).to eql 1
            # king is 10
            expect(k.value).to eql 10

        end
    end

end


describe Deck do

    describe "#init" do
        it "contains 52 cards when initialized" do
            x = Deck.new

            expect(x.cards.count).to eql 52
            x.cards.each do |c|
                expect(c).to be_an_instance_of Card
            end
        end
    end

    describe "#draw" do
        it "yeilds a card when called" do
            d = Deck.new
            y = d.draw

            expect(y).to be_an_instance_of Card
        end

        it "reduces number of cards when called" do
            d = Deck.new
            starting_count = d.cards.count   # count before draw
            y = d.draw

            expected_count = starting_count - 1
            expect(d.cards.count).to eql expected_count
        end
    end

end


describe Shoe do

    describe "#init" do
        it "contains 52 cards per deck, n decks when initialized" do
            n = 2
            s = Shoe.new n
            expected_count = 52 * n
            expect(s.remaining).to eql expected_count

            n = 4
            s = Shoe.new n
            expected_count = 52 * n
            expect(s.remaining).to eql expected_count
        end
    end

end


describe Hand do

    describe "@cards" do
        it "holds cards that are added to it" do
            h = Hand.new
            s = Card.new :hearts, :six
            h.add s
            a = Card.new :spades, :ace
            h.add a

            expect(h.cards.count).to eql 2
            expect(h.cards.include?(s)).to eql true
            expect(h.cards.include?(a)).to eql true
        end

        it "returns count of cards in hand" do
            h = Hand.new

            h.add Card.new :hearts, :six
            expect(h.count).to eql 1

            h.add Card.new :spades, :ace
            expect(h.count).to eql 2
        end
    end

    describe "@surrender" do
        it "has initial value of false" do
            h = Hand.new
            expect(h.surrender?).to eql false
        end

        it "can be toggled to true with surrender!" do
            h = Hand.new
            h.surrender!
            expect(h.surrender?).to eql true
        end
    end

    describe "@doubled" do
        it "has initial value of false" do
            h = Hand.new
            expect(h.doubled?).to eql false
        end

        it "can be toggled to true with doubled!" do
            h = Hand.new
            h.doubled!
            expect(h.doubled?).to eql true
        end
    end

    describe "#has_ace?" do
        it "detects if an ace is in the hand" do
            h = Hand.new
            h.add Card.new :hearts, :six
            h.add Card.new :spades, :ace
            expect(h.has_ace?).to eql true
        end

        it "detects if an ace is not in the hand" do
            h = Hand.new
            h.add Card.new :hearts, :six
            h.add Card.new :spades, :six
            expect(h.has_ace?).to eql false
        end
    end

    describe "#has_split?" do
        it "detects if the hand is a split" do
            h = Hand.new
            h.add Card.new :hearts, :six
            h.add Card.new :spades, :six
            expect(h.has_split?).to eql true
        end

        it "detects if the hand is not a split" do
            h = Hand.new
            h.add Card.new :hearts, :six
            h.add Card.new :spades, :six
            h.add Card.new :clubs, :six
            expect(h.has_split?).to eql false

            j = Hand.new
            j.add Card.new :hearts, :six
            j.add Card.new :spades, :five
            expect(j.has_split?).to eql false
        end
    end

    describe "#has_blackjack?" do
        it "detects if the hand is a blackjack" do
            h = Hand.new
            h.add Card.new :hearts, :ace
            h.add Card.new :spades, :jack
            expect(h.has_blackjack?).to eql true
        end

        it "detects if the hand is not a blackjack" do
            h = Hand.new
            h.add Card.new :hearts, :six
            h.add Card.new :hearts, :ace
            h.add Card.new :spades, :jack
            expect(h.has_blackjack?).to eql false

            j = Hand.new
            j.add Card.new :hearts, :six
            j.add Card.new :spades, :five
            expect(j.has_blackjack?).to eql false
        end
    end

    describe "#upcard" do
        it "returns the value of the 'upcard'" do
            h = Hand.new
            # the upcard is the second card delt
            h.add Card.new :hearts, :six
            h.add Card.new :spades, :king
            expect(h.upcard).to eql 10
        end

        it "returns nil when there's no 'upcard'" do
            h = Hand.new
            # only one card delt, upcard would be second
            h.add Card.new :hearts, :six
            expect(h.upcard).to eql nil
        end
    end

    describe "#score" do
        it "can detect and score a blackjack" do
            h = Hand.new

            # add two and check for the blackjack
            h.add Card.new :hearts, :ace
            h.add Card.new :spades, :king
            expect(h.score).to eql [ 'blackjack', 21 ]

            # add a third and make sure it's no blackjack
            w = Card.new :clubs, :ace
            h.add w
            expect(h.score[0]).not_to eql 'blackjack'
        end

        it "can score hands with hard values (no aces)" do
            h = Hand.new

            # add cards (not aces) and check for 'hard' score

            f = Card.new :hearts, :four
            h.add f
            t = Card.new :spades, :three
            h.add t
            expect(h.score).to eql [ 'hard', 7 ]

            k = Card.new :spades, :king
            h.add k
            expect(h.score).to eql [ 'hard', 17 ]

            w = Card.new :clubs, :two
            h.add w
            expect(h.score).not_to eql [ 'hard', '19' ]
        end

        it "can score hands with soft values (aces)" do
            h = Hand.new
            h.add Card.new :hearts, :four
            h.add Card.new :spades, :ace
            expect(h.score).to eql [ 'soft', 15 ]

            h.add Card.new :spades, :ace
            expect(h.score).to eql [ 'soft', 16 ]

            h.add Card.new :spades, :nine
            expect(h.score).to eql [ 'hard', 15 ]

            h.add Card.new :spades, :ace
            expect(h.score).to eql [ 'hard', 16 ]
        end
    end

    describe "#bust?" do
        it "detects a hand is bust" do
            h = Hand.new
            h.add Card.new :hearts, :ten
            h.add Card.new :spades, :ten
            h.add Card.new :diamonds, :ten
            expect(h.bust?).to eql true
        end

        it "detects a hand is not bust" do
            h = Hand.new
            h.add Card.new :hearts, :ten
            h.add Card.new :spades, :seven
            expect(h.bust?).to eql false
        end
    end

    describe "#stand?" do
        it "stands on a 30" do
            # create a hand with score of 30
            h = Hand.new
            h.add Card.new :hearts, :ten
            h.add Card.new :spades, :ten
            h.add Card.new :diamonds, :ten
            # test
            expect(h.stand?).to eql true
        end

        it "stands on 17" do
            h = Hand.new
            h.add Card.new :hearts, :ten
            h.add Card.new :spades, :seven
            # test
            expect(h.stand?).to eql true
        end

        it "hits on 16" do
            h = Hand.new
            h.add Card.new :hearts, :ten
            h.add Card.new :spades, :six
            # test
            expect(h.stand?).to eql false
        end
    end

end
