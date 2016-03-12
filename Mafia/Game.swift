//
//  Game.swift
//  Mafia
//
//  Created by Charles Yeh on 3/3/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class Game: NSObject {
    
    var token: String = ""
    var state: GameState = .INITIALIZING
    
    var winner: Winner?
    var players: [Player] = []
    
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    var rounds: [Round] = []
    
    var dictionary: NSDictionary?
    
    init(gameToken: String) {
        super.init()
        token = gameToken
    }
    
    init(fromResponse response: AnyObject) {
        super.init()
        setValues(response as! NSDictionary)
    }
    
    func setValues(data: NSDictionary) {
        self.dictionary = data
        
        let game = data["game"] as! NSDictionary
        
        token = game["token"] as! String
        state = GameState(rawValue: game["state"] as! String)!
        if let rawWinner = game["winner"] as? String {
            winner = Winner(rawValue: rawWinner)
        }
        players = (game["players"] as! NSArray).map { (playerData) -> Player in
            Player(fromDictionary: playerData as! NSDictionary)
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        createdAt = formatter.dateFromString(game["created_at"] as! String)
        updatedAt = formatter.dateFromString(game["updated_at"] as! String)
        
        rounds = (game["rounds"] as! NSArray).map { (round) in
            return Round(fromDictionary: round as! NSDictionary)
        }
    }
}

enum GameState: String {
    case INITIALIZING = "initializing"
    case IN_PROGRESS = "in_progress"
    case FINISHED = "finished"
}

enum Winner: String {
    case MAFIA = "mafia"
    case TOWNSPERSON = "townsperson"
}