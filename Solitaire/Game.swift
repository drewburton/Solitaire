//
//  Game.swift
//  Solitaire
//
//  Created by Drew Burton on 10/30/24.
//

import UIKit


class Game {
    static let sharedInstance = Game()
    
    private init() {
        
    }
    
    func moveTopCard(from: CardStack, to: CardStack, faceUp: Bool, makeNewTopCardFaceup: Bool) {
        var card = from.topCard()
        if (card != nil) {
            card!.faceUp = faceUp
            to.addCard(card: card!)
            from.popCards(numberToPop: 1, makeNewTopCardFaceup: makeNewTopCardFaceup)
        }
    }
    
    func copyCards(from: CardStack, to: CardStack) {
        from.cards.forEach( { _ in self.moveTopCard(from: from, to: to, faceUp: false, makeNewTopCardFaceup: false) })
    }
    
    func shuffle() {
        Model.sharedInstance.shuffle()
    }
    
    func initalizeDeal() {
        self.shuffle()
        
        Model.sharedInstance.tableauStacks.forEach { $0.removeAllCards() }
        Model.sharedInstance.foundationStacks.forEach { $0.removeAllCards() }
        Model.sharedInstance.wasteStack.removeAllCards()
        Model.sharedInstance.dealStack.removeAllCards()
    }
    
}


