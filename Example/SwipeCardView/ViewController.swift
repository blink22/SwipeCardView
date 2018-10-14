//
//  ViewController.swift
//  SwipeCards
//
//  Created by Omar Eissa on 10/9/18.
//  Copyright © 2018 Omar Eissa. All rights reserved.
//

import UIKit
import SwipeCardView

class ViewController: UIViewController, SwipeCardViewDataSource, SwipeCardViewDelegate {
    
    @IBOutlet weak var swipeCardView: SwipeCardView!
    
    override func viewWillAppear(_ animated: Bool) {
        swipeCardView.dataSource = self
        swipeCardView.delegate = self
    }
    
    // MARK: - SwipeCardViewDataSource
    func numberOfCards(_ swipeCardView: SwipeCardView) -> Int {
        return 10000
    }
    
    func swipeCardView(_ swipeCardView: SwipeCardView, viewForIndex index: Int) -> UIView {
        switch index % 5 {
        case 0:
            return UIImageView(image: UIImage(named: "J♠️"))
        case 1:
            return UIImageView(image: UIImage(named: "J♥️"))
        case 2:
            return UIImageView(image: UIImage(named: "J♣️"))
        case 3:
            return UIImageView(image: UIImage(named: "J♦️"))
        case 4:
            return UIImageView(image: UIImage(named: "K♥️"))
        default:
            return UIImageView(image: UIImage(named: "J♠️"))
        }
    }
    
    // MARK: - SwipeCardViewDataSource
    func swipeCardView(_ swipeCardView: SwipeCardView, cardWasSwipedIn direction: CardMoveDirection, at index: Int) {
        print("\(direction)  \(index)")
    }
    
    @IBAction func revert(_ sender: UIButton) {
        swipeCardView.revertIfPossible()
    }
}

