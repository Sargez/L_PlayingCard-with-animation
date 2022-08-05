//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by 1C on 21/04/2022.
//

import Foundation

struct PlayingCard: CustomStringConvertible {
    
    var description: String { return "\(rank)\(suit)" }
    
    var suit: Suit
    var rank: Rank
        
    enum Suit: String, CustomStringConvertible {
       
        var description: String { return rawValue }
                
        case spades = "♠️"
        case heats = "❤️"
        case diamonds = "♦️"
        case clubs = "♣️"
        
        static var allSuits : [Suit] { [Suit.spades, .diamonds, .heats, .clubs] }
    }
    
    enum Rank: CustomStringConvertible {
        
        var description: String {
            switch self {
            case .ace: return "A"
            case .numeric(let pips): return String(pips)
            case.faces(let kind): return kind
            }
        }
        
        case ace
        case faces (String)
        case numeric (Int)
        
        var order: Int {
            switch self {
            case Rank.ace: return 1
            case Rank.numeric(let pips): return pips
            case Rank.faces(let kind) where kind == "J": return 11
            case Rank.faces(let kind) where kind == "Q": return 12
            case Rank.faces(let kind) where kind == "K": return 13
            default: return 0
            }
        }
        
        static var allRanks: [Rank] {
            var all = [Rank.ace]
            for pips in 2...10 {
                all.append(.numeric(pips))
            }
            all += [Rank.faces("J"), .faces("Q"), .faces("K")]
            
            return all
        }
        
    }
    
    
    
}

//let mSuit = PlayingCard.Suit(rawValue: "❤️")
//let rawValueSuit = PlayingCard.Suit.spades.rawValue
