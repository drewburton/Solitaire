//
//  CardStack.swift
//  Solitaire
//
//  Created by Drew Burton on 10/29/24.
//

protocol CardStackDelegate : AnyObject {
    func refresh()
}

class CardStack {
    weak var delegate: CardStackDelegate?
    
    var cards = [Card]()
    
    func addCard(card: Card) {
        cards.append(card)
        delegate?.refresh()
    }
    
    func canAccept(droppedCard: Card) -> Bool {
        return false
    }
    
    func topCard() -> Card? {
        return cards.last
    }
    
    func faceUpCards() -> [Card]? {
        var faceUpCards = [Card]()
        
        for card in cards {
            if card.faceUp {
                faceUpCards.append(card)
            }
        }
        
        return faceUpCards
    }
    
    func removeAllCards() {
        self.cards.removeAll()
        delegate?.refresh()
    }
    
    func popCards(numberToPop: Int, makeNewTopCardFaceup: Bool) {
        guard cards.count >= numberToPop else {
            assert(false, "Attempted to pop more cards than are on the stack!")
            return
        }
        
        cards.removeLast(numberToPop)
        
        if makeNewTopCardFaceup {
            var card = self.topCard()
            if card != nil {
                cards.removeLast()
                card!.faceUp = true
                cards.append(card!)
            }
        }
        delegate?.refresh()
    }
    
    var isEmpty: Bool {
        return cards.isEmpty
    }
    
}

final class TableauStack : CardStack {
    
    override func canAccept(droppedCard: Card) -> Bool {
        
        if let topCard = self.topCard() {
            let (_, topCardRank) = topCard.getCardSuitAndRank()
            let (_, droppedCardRank) = droppedCard.getCardSuitAndRank()
            if topCard.faceUp && !topCard.cardSuitIsSameColor(card: droppedCard) && (droppedCardRank == topCardRank - 1) {
                return true
            }
        } else {
            // if pile is empty accept any King
            if droppedCard.isKing {
                return true
            }
        }
        
        return false
    }
}

final class FoundationStack : CardStack {
   
    // TODO: check functionality
    override func canAccept(droppedCard: Card) -> Bool {
        if cards.isEmpty {
            return droppedCard.isAce      // if pile is empty, take any Ace
        }
        
        if let topCard = self.topCard() {
            let (topSuit, topRank) = topCard.getCardSuitAndRank()
            let (droppedSuit, droppedRank) = droppedCard.getCardSuitAndRank()
            if topSuit == droppedSuit && droppedRank == topRank + 1  {
                return true
            }
        }
        
        return false
    }
}

final class WasteStack : CardStack {
    
    override func canAccept(droppedCard: Card) -> Bool {
        // can't drop anything here
        return false
    }
}

final class DealStack : CardStack {
    
    override func canAccept(droppedCard: Card) -> Bool {
        // can't drop anything here
        return false
    }
}
