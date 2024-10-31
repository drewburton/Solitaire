//
//  ViewController.swift
//  Solitaire
//
//  Created by Drew Burton on 10/29/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
            
        let solitaireView = SolitaireGameView(frame: self.view.bounds)
        self.view.addSubview(solitaireView)
    }


}

