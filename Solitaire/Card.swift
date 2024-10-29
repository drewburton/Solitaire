import UIKit

struct Card {
    let value: Int
    var faceUp: Bool
    
    func getCardSuitAndRank() -> (suit: Suit, rank: Int) {
        let suit = Suit(rawValue: self.value / numberOfCardsInSuit)!
        let rank = (self.value % numberOfCardsInSuit)
        
        return (suit, rank)
    }
    
    private func getSuitColor() -> UIColor {
        
        let suit = Suit(rawValue: self.value / numberOfCardsInSuit)!
        var color: UIColor
        
        switch (suit) {
            case .spades, .clubs:
                color = .black
            case .hearts, .diamonds:
                color = .red
        }
        
        return color
    }
    
    func cardSuitIsSameColor(card: Card) -> Bool {
        return getSuitColor() == card.getSuitColor()
    }
    
    var isKing: Bool {
        return self.value % numberOfCardsInSuit == 12
    }
    
    var isAce: Bool {
        return self.value % numberOfCardsInSuit == 0
    }
}
