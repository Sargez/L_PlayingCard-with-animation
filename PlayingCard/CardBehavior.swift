//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by 1C on 15/05/2022.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
  
    private lazy var collisionBehavior: UICollisionBehavior = {
            
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
        
    }()
    
    private lazy var behaviorItem: UIDynamicItemBehavior = {
       
        let behavior = UIDynamicItemBehavior()
        behavior.resistance = CGFloat(0.0)
        behavior.elasticity = CGFloat(1.0)
        behavior.allowsRotation = false
        return behavior
        
    }()
    
    private func addPush(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.magnitude = CGFloat(1.0) //+ CGFloat(1.0).arc4random
        
        if let referenceViewBounds = self.dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceViewBounds.midX, y: referenceViewBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x,y) where x < center.x && y < center.y:
                push.angle = CGFloat(CGFloat.pi/2).arc4random
            case let (x,y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi - CGFloat(CGFloat.pi/2).arc4random
            case let (x,y) where x < center.x && y > center.y:
                push.angle = (-CGFloat.pi/2).arc4random
            case let (x,y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi + CGFloat(CGFloat.pi/2).arc4random
            default:
                push.angle = CGFloat(2*CGFloat.pi).arc4random
            }
        }

//        push.angle = CGFloat(2*CGFloat.pi).arc4random
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        behaviorItem.addItem(item)
        addPush(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        behaviorItem.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(behaviorItem)
    }
    
    convenience init(in anymator: UIDynamicAnimator) {
        self.init()
        anymator.addBehavior(self)
    }
    
    
}

extension CGFloat {
    var arc4random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(Int32(self * 5))))
        } else if self < 0 {
            return -CGFloat(arc4random_uniform(UInt32(Int32(abs(self * 5)))))
        } else {
            return 0
        }
    }
}
