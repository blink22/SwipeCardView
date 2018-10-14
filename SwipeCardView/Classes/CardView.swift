		//
//  CardView.swift
//  SwipeCards
//
//  Created by Omar Eissa on 10/9/18.
//  Copyright © 2018 Omar Eissa. All rights reserved.
//

import UIKit
        
protocol CardDelegate: class {
    var allowedDirections: [CardMoveDirection] { get }
    func card(_ card: CardView, wasSwipedIn direction: CardMoveDirection)
}
        
class CardView: UIView {

    var originalPoint: CGPoint!
    var fullDistance: CGSize!
    var delegate: CardDelegate?
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init(contentView view: UIView) {
        super.init(frame: CGRect.zero)
        setupView(withContentView: view)
    }
    
    func setupView(withContentView contentView: UIView) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowOpacity = 0.5
        
        isUserInteractionEnabled = false
        
        panGestureRecognizer = UIPanGestureRecognizer(
                target: self,
                action: #selector(moveCard(byHandlingGestureRecognizedBy:)))
        addGestureRecognizer(panGestureRecognizer)
        
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
        
        addSubview(contentView)
        addConstraints(contentView)
    }
    
    private func addConstraints(_ contentView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let width = NSLayoutConstraint(
            item: contentView,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.width,
            multiplier: 1.0,
            constant: 0)
        let height = NSLayoutConstraint(
            item: contentView,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.height,
            multiplier: 1.0,
            constant: 0)
        let top = NSLayoutConstraint (
            item: contentView,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.top,
            multiplier: 1.0,
            constant: 0)
        let leading = NSLayoutConstraint (
            item: contentView,
            attribute: NSLayoutAttribute.leading,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.leading,
            multiplier: 1.0,
            constant: 0)
        
        addConstraints([width,height,top,leading])
    }

    @objc func moveCard(byHandlingGestureRecognizedBy recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self)
        
        switch recognizer.state {
        case .began:
            originalPoint = center
            fullDistance = CGSize(width: center.x + bounds.width / 2,
                                  height: center.y + bounds.height / 2)
        case .changed:
            center = CGPoint(x: originalPoint.x + translation.x, y: originalPoint.y + translation.y)
            alpha = max(1 - max(fabs(translation.x / fullDistance.width / 2),
                                fabs(translation.y / fullDistance.height / 2)),
                        CardView.minAlpha)
            transform = CGAffineTransform(rotationAngle: .pi / 8 * (translation.x / fullDistance.width))
        case .ended:
            swipeFinished(withTranslation: translation)
        default:
            break
        }
    }
    
    func swipeFinished(withTranslation translation: CGPoint) {
        if let isAllowed = delegate?.allowedDirections.contains(.right),
            isAllowed && translation.x > originalPoint.x * CardView.removalRatio{
            
            removeCard(withDirection: .right)
        } else if let isAllowed = delegate?.allowedDirections.contains(.left),
            isAllowed &&  -translation.x > originalPoint.x * CardView.removalRatio {
            
            removeCard(withDirection: .left)
        } else if let isAllowed = delegate?.allowedDirections.contains(.down),
            isAllowed && translation.y > originalPoint.y * CardView.removalRatio {
            
            removeCard(withDirection: .down)
        } else if let isAllowed = delegate?.allowedDirections.contains(.up),
            isAllowed && -translation.y > originalPoint.y * CardView.removalRatio {
            
            removeCard(withDirection: .up)
        } else {
            UIView.animate(
                withDuration: CardView.animationDuration, delay: 0,
                usingSpringWithDamping: CardView.animationSpringDamping,
                initialSpringVelocity: 0, options: [.allowUserInteraction],
                animations: { [weak self] in
                    self?.center = self!.originalPoint
                    self?.alpha = 1
                    self?.transform = CGAffineTransform(rotationAngle: 0)
            })
        }
    }
    
    func removeCard(withDirection direction: CardMoveDirection) {
        delegate?.card(self, wasSwipedIn: direction)
        let animation: () -> Void
        if direction == .left || direction == .right {
            animation = { [weak self] in
                
                self?.center = CGPoint(x: self!.originalPoint.x * (direction == .right ? 4 : -4),
                                       y: self!.center.y)
                self?.transform = CGAffineTransform(rotationAngle: (direction == .right ? 1 : -1))
                
            }
        } else {
            animation = { [weak self] in
                self?.center = CGPoint(x: self!.center.x,
                                       y: self!.originalPoint.y * (direction == .down ? 4 : -4))
            }
        }
        UIView.animate(withDuration: CardView.animationDuration, delay: 0,
                       options: [.allowUserInteraction], animations: animation,
                       completion: { [weak self] _ in
                            self?.removeFromSuperview()})
    }
}
    
extension CardView {
    static let cornerRadiusToBoundsHeight: CGFloat = 0.5
    static let removalRatio: CGFloat = 0.7
    static let animationDuration: TimeInterval = 0.3
    static let animationSpringDamping: CGFloat = 0.5
    static let minAlpha: CGFloat = 0.5
}
        
    
public enum CardMoveDirection {
    case left
    case right
    case up
    case down
}
