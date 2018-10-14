
//
//  SwipeCardView.swift
//  SwipeCards
//
//  Created by Omar Eissa on 10/10/18.
//  Copyright © 2018 Omar Eissa. All rights reserved.
//

import UIKit


public protocol SwipeCardViewDataSource: class {
    
    func numberOfCards(_ swipeCardView: SwipeCardView) -> Int
    func swipeCardView(_ swipeCardView: SwipeCardView, viewForIndex index: Int) -> UIView
}

public protocol SwipeCardViewDelegate: class {
    func swipeCardView(_ swipeCardView: SwipeCardView, cardWasSwipedIn direction: CardMoveDirection, at index: Int)
}

@IBDesignable public class SwipeCardView: UIView, CardDelegate {
    
    @IBInspectable public var numberOfVisibleCards: Int = 3 {
        didSet {
            layoutCards()
        }
    }
    @IBInspectable public var yOffset: Int = 10 {
        didSet {
            layoutCards()
        }
    }
    @IBInspectable public var cardWidthToViewWidthRatio: CGFloat = 0.5 {
        didSet {
            layoutCards()
        }
    }
    
    public var allowedDirections: [CardMoveDirection] = [.left, .right, .up, .down]
    
    private var currentIndex: Int {
        get {
            return (visibleCards.last?.index ?? -1) + 1
        }
    }
    
    private var cardsFinished: Bool = false
    
    private var visibleCards = [(index: Int, cardView: CardView)]()
    
    public var dataSource: SwipeCardViewDataSource? {
        didSet {
            visibleCards = []
            subviews.forEach({ $0.removeFromSuperview() })
        }
    }
    
    public var delegate: SwipeCardViewDelegate?
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutCards()
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutCards()
    }
    
    public func revertIfPossible() {
        guard let firstIndex = visibleCards.first?.index, firstIndex > 0,
            let dataSource = dataSource else { return }
        
        cardsFinished = true
        visibleCards.popLast()?.cardView.removeFromSuperview()
        
        let cardView = CardView(contentView: dataSource
            .swipeCardView(self, viewForIndex: firstIndex - 1))
        cardView.delegate = self
        
        addSubview(cardView)
        visibleCards.insert((firstIndex - 1, cardView), at: 0)
        
        layoutCards()
    }
    
    private func addCardstoView() {
        if let dataSource = dataSource, !cardsFinished {
            let numOfNeededCards = min(dataSource.numberOfCards(self) - currentIndex,
                                       numberOfVisibleCards - visibleCards.count)
            for _ in 0..<numOfNeededCards {
                let cardView = CardView(contentView: dataSource
                    .swipeCardView(self,
                                   viewForIndex: currentIndex))
                cardView.delegate = self
                
                if visibleCards.count == 0 {
                    addSubview(cardView)
                } else {
                    insertSubview(cardView, belowSubview: visibleCards.last!.cardView)
                }
                visibleCards.append((currentIndex, cardView))
            }
        }
    }
    
    private func layoutCards() {
        addCardstoView()
        
        for (index, card) in visibleCards.enumerated() {
            let width = bounds.width * cardWidthToViewWidthRatio
            let height = bounds.height - CGFloat((numberOfVisibleCards - 1) * yOffset)
            let frame = CGRect(x: (bounds.width - width) / 2,y: CGFloat(index * yOffset),
                               width: width, height: height)
            if index == 0 {
                card.cardView.isUserInteractionEnabled = true
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction],
                           animations: { card.cardView.frame = frame })
            
        }
    }
    
    // MARK: - CardDelegate
    func card(_ card: CardView, wasSwipedIn direction: CardMoveDirection) {
        delegate?.swipeCardView(self, cardWasSwipedIn: direction, at: visibleCards.first!.index)
        cardsFinished = visibleCards.remove(at: 0).index == dataSource!.numberOfCards(self) - 1
    }
    
    
}
