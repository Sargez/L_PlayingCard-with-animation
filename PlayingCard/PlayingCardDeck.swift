//
//  PlayingCardDeck.swift
//  PlayingCard
//
//  Created by 1C on 21/04/2022.
//

import Foundation

struct PlayingCardDeck {
   

    private (set) var cards = [PlayingCard]()
    
    mutating func draw() -> PlayingCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
   
    init() {
        for suit in PlayingCard.Suit.allSuits {
            for rank in PlayingCard.Rank.allRanks {
                cards.append(PlayingCard.init(suit: suit, rank: rank))
            }
        }
    }
    
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(Int32(self))))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(Int32(abs(self)))))
        } else {
            return 0
        }
    }
}
