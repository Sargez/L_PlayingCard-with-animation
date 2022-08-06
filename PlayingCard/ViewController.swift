//
//  ViewController.swift
//  PlayingCard
//
//  Created by 1C on 21/04/2022.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    private lazy var animator = UIDynamicAnimator.init(referenceView: view)
    
    private lazy var cardBehavior: CardBehavior = {
        CardBehavior.init(in: animator)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CMMotionManager.shared.isAccelerometerAvailable {
            cardBehavior.gravityBehavior.magnitude = 1
            CMMotionManager.shared.accelerometerUpdateInterval = 1/10
            CMMotionManager.shared.startAccelerometerUpdates(to: .main) { data, error in
                if var x = data?.acceleration.x, var y = data?.acceleration.y {
                    
                    switch UIDevice.current.orientation {
                    case .portrait:
                        y = -1 * y
                    case .portraitUpsideDown: break
                    case .landscapeRight: swap(&x, &y); y = -1*y
                    case .landscapeLeft: swap(&x, &y)
                    default:
                        x = 0; y = 0
                    }
                    
                    self.cardBehavior.gravityBehavior.gravityDirection = CGVector(dx: x, dy: y)
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1)/2) {
            let card = deck.draw()!
            cards += [card,card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                 action: #selector(flipCard(_:))))
            

            cardBehavior.addItem(cardView)
            
            
        }
    }
    
    private var faceUpCardView: [PlayingCardView] {
        cardViews.filter {$0.isFaceUp && !$0.isHidden && $0.alpha == 1 && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)}
    }
    
    private var faceUpCardViewMatched: Bool {
        return faceUpCardView.count == 2
                    && faceUpCardView[0].rank == faceUpCardView[1].rank
                    && faceUpCardView[0].suit == faceUpCardView[1].suit
        
    }
    
    private var lastChosenCard: PlayingCardView?
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case UIGestureRecognizer.State.ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardView.count < 2 {
                
                lastChosenCard = chosenCardView
                
                //останавливает карту, убирая ее из поведения аниматора
                cardBehavior.removeItem(chosenCardView)
                
                //перевернем выбранную карту на противоположную сторону
                UIView.transition(with: chosenCardView,
                                  duration: 0.5,
                                  options: [.transitionFlipFromLeft],
                                  animations: {chosenCardView.isFaceUp = !chosenCardView.isFaceUp},
                                  
                                  completion: {finish in
                                    
                                    let cardsToAnimate = self.faceUpCardView
                                    
                                    if self.faceUpCardViewMatched {
                                        //2 карты совпали. делаем 2х ступенчатую анимацию
                                        //а) карты увеличваются
                                        //б) карты уменьшаются и расстворяются
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 0.6,
                                            delay: 0,
                                            options: [],
                                            animations: {cardsToAnimate.forEach {
                                                $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)}
                                            },
                                            
                                            completion: {position in
                                                if position == .end {
                                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                                        withDuration: 0.8,
                                                        delay: 0,
                                                        options: [],
                                                        animations: { cardsToAnimate.forEach {
                                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                            $0.alpha = 0
                                                        }
                                                        },
                                                        completion: {
                                                            position in
                                                            cardsToAnimate.forEach {
                                                                $0.isHidden = true
                                                                $0.alpha = 1
                                                                $0.transform = .identity
                                                            }
                                                        }
                                                    )
                                                }
                                            }
                                        )
                                        
                                        
                                    } else if cardsToAnimate.count == 2 { //!!! no memory cycle here
                                        //переворот 2х не совпавших карт обратно лицом вниз
                                        if self.lastChosenCard == chosenCardView {
                                            cardsToAnimate.forEach { cardView in
                                                UIView.transition(with: cardView,
                                                                  duration: 0.5,
                                                                  options: [.transitionFlipFromLeft],
                                                                  animations: {cardView.isFaceUp = false},
                                                                  completion: {finish in
                                                                    self.cardBehavior.addItem(cardView)
                                                                  })
                                            }
                                        }
                                    } else if !chosenCardView.isFaceUp {
                                        self.cardBehavior.addItem(chosenCardView)
                                    }
                                  }
                )
            }
        default:
            break
        }
    }


}



