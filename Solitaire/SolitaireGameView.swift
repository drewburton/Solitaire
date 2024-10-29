//
//  SolitaireGameView.swift
//  Solitaire
//
//  Created by Drew Burton on 10/29/24.
//

import UIKit

class SolitaireGameView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hex: 0x004D2C)
        
        self.initStackViews()
        
        self.dealCards()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initStackViews() {}
    private func dealCards() {}

}
