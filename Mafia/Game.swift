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
    var state: String = ""
    var players: [Player] = []
    
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    var rounds: [Round]?
    
    var dictionary: NSDictionary?
    
    init(fromResponse response: AnyObject) {
        
        let data = response as! NSDictionary
        self.dictionary = data
        
        if let game = data["game"] as? NSDictionary {
            
            token = game["token"] as! String
            state = game["state"] as! String
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
        } else {
            NSLog("Failed to deserialize JSON \(data)")
        }
    }
}
