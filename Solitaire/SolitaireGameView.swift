//
//  SolitaireGameView.swift
//  Solitaire
//
//  Created by Drew Burton on 10/29/24.
//

import UIKit

fileprivate let SPACING = CGFloat(UIScreen.main.bounds.width > 750 ? 10.0 : 3.0)
let CARD_WIDTH = CGFloat((UIScreen.main.bounds.width - CGFloat(7.0 * SPACING)) / 7.0)
let CARD_HEIGHT = CARD_WIDTH * 1.42

private extension Selector {
    static let handleTap = #selector(SolitaireGameView.newDealAction)
}

class SolitaireGameView: UIView {
    
    private var foundationStacks = [FoundationStackView]()
    private var tableauStackViews = [TableauStackView]()
    private var dealStackView = DealStackView(frame: CGRect.zero)
    private var wasteStackView = WasteStackView()
    private var baseTableauFrameRect = CGRect.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hex: 0x004D2C)
        
        self.initStackViews()
        
        self.dealCards()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initStackViews() {
        let baseRect = CGRect(x: 4.0, y: scaled(value: 110.0), width: CARD_WIDTH, height: CARD_HEIGHT)
        var foundationRect = baseRect
        for index in 0 ..< 4 {
            let stackView = FoundationStackView(frame: foundationRect, cards: Model.sharedInstance.foundationStacks[index])
            self.addSubview(stackView)
            self.foundationStacks.append(stackView)
            foundationRect = foundationRect.offsetBy(dx: CGFloat(CARD_WIDTH + SPACING), dy: 0.0)
        }
        
        foundationRect = foundationRect.offsetBy(dx: CGFloat(CARD_WIDTH + SPACING), dy: 0.0)
        self.wasteStackView = WasteStackView(frame: foundationRect, cards: Model.sharedInstance.wasteStack)
        self.addSubview(self.wasteStackView)
        
        foundationRect = foundationRect.offsetBy(dx: CGFloat(CARD_WIDTH + SPACING), dy: 0.0)
        self.dealStackView = DealStackView(frame: foundationRect, cards: Model.sharedInstance.dealStack)
        self.addSubview(self.dealStackView)
        
        var gameStackRect = baseRect.offsetBy(dx: 0.0, dy: CGFloat(CARD_HEIGHT + scaled(value: 12.0)))
        self.baseTableauFrameRect = gameStackRect
        for index in 0 ..< 7 {
            let stackView = TableauStackView(frame: gameStackRect, cards: Model.sharedInstance.tableauStacks[index])
            self.addSubview(stackView)
            self.tableauStackViews.append(stackView)
            gameStackRect = gameStackRect.offsetBy(dx: CGFloat(CARD_WIDTH + SPACING), dy: 0.0)
        }
        
        let buttonFrame = CGRect(x: 1.0, y: scaled(value: 60.0), width: scaled(value: 70.0), height: scaled(value: 30.0))
        let newDealButton = UIButton(frame: buttonFrame)
        newDealButton.setTitle("New Deal", for: .normal)
        newDealButton.setTitleColor(.white, for: .normal)
        newDealButton.titleLabel?.font = .systemFont(ofSize: scaled(value: 14.0))
        newDealButton.addTarget(self, action: .handleTap, for: .touchUpInside)
        self.addSubview(newDealButton)
    }
    
    @objc func newDealAction() {
        self.dealCards()
    }
    
    private func dealCards() {
        Game.sharedInstance.initalizeDeal()
        
        var tableauFrame = self.baseTableauFrameRect
        var cardValuesIndex = 0
        for outerIndex in 0 ..< 7 {
            self.tableauStackViews[outerIndex].frame = tableauFrame
            for innerIndex in (0 ... outerIndex) {
                Model.sharedInstance.tableauStacks[outerIndex].addCard(card: Card(value: Model.sharedInstance.deck[cardValuesIndex], faceUp: outerIndex == innerIndex))
                cardValuesIndex += 1
            }
            tableauFrame = tableauFrame.offsetBy(dx: CGFloat(CARD_WIDTH + SPACING), dy: 0.0)
        }
        
        for _ in cardValuesIndex ..< 52 {
            Model.sharedInstance.dealStack.addCard(card: Card(value: Model.sharedInstance.deck[cardValuesIndex], faceUp: false))
            cardValuesIndex += 1
        }
    }

}
// MARK: Click on cards
extension SolitaireGameView {
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        let touch = touches.first!
        handleTap(inView: touch.view!)
    }
    
    // if a card in the waste stack or one of the tableau stacks is clicked,
    // see if it can be added to a foundation stack
    // if you copy / paste these two functions and replace Foundation with Tableau
    // you can try moving them to a tableau stack if it doesn't go into a foundation stack
    // or, you can just let the user do something for themself :-)
    func handleTap(inView: UIView) {
        if let wasteStack = inView as? WasteStackView {
            if let card = wasteStack.cards.topCard() {
                if self.addCardToFoundation(card: card) || self.addCardToTableau(card: card){
                    wasteStack.cards.popCards(numberToPop: 1, makeNewTopCardFaceup: true)
                }
            }
        } else if let tableauStack = inView as? TableauStackView {
            if let card = tableauStack.cards.topCard() {
                if self.addCardToFoundation(card: card) {
                    tableauStack.cards.popCards(numberToPop: 1, makeNewTopCardFaceup: true)
                }  else if let cards = tableauStack.cards.faceUpCards() {
                    let result = self.moveTableauStack(currentStack: tableauStack, cards:cards)
                    if result.moved {
                        tableauStack.cards.popCards(numberToPop: result.count, makeNewTopCardFaceup: true)
                    }
                }
            }
        }
    }
    
    private func addCardToFoundation(card: Card) -> Bool {
        var addedCard = false
        
        for stack in self.foundationStacks {
            if stack.cards.canAccept(droppedCard: card) {
                stack.cards.addCard(card: card)
                addedCard = true
                break
            }
        }
        
        return addedCard
    }
    
    private func addCardToTableau(card: Card) -> Bool {
        var addedCard = false
       
        for stack in self.tableauStackViews {
            if stack.cards.canAccept(droppedCard: card) {
                stack.cards.addCard(card: card)
                addedCard = true
                break
            }
        }
        return addedCard
    }
    
    private func moveTableauStack(currentStack: TableauStackView, cards: [Card]) -> (moved: Bool, count: Int) {
        // check if any of the cards in the stack can be added to any of the other tableau stacks
        for i in 0...(cards.count - 1) {
            for stack in self.tableauStackViews {
                // ignore the current stack
                if stack == currentStack {
                    continue
                }
                if stack.cards.canAccept(droppedCard: cards[i]) {
                    // move the card and all the ones on top of it
                    for j in i...(cards.count - 1) {
                        stack.cards.addCard(card: cards[j])
                    }
                    return (true, cards.count - i)
                }
            }
        }
        return (false, 0)
    }
}
