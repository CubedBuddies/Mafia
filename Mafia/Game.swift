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
            
            createdAt = game["created_at"] as? NSDate
            updatedAt = game["updated_at"] as? NSDate
        } else {
            NSLog("Failed to deserialize JSON \(data)")
        }
    }
    
    static var _currentGame: Game?
    class var currentGame: Game? {
        get {
            if _currentGame == nil {
            let defaults = NSUserDefaults.standardUserDefaults()
            let gameData = defaults.objectForKey("currentGameData") as? NSData
            if let gameData = gameData {
                let dictionary = try! NSJSONSerialization.JSONObjectWithData(gameData, options: []) as! NSDictionary
                _currentGame = Game(fromResponse: dictionary)
            }
        }
        return _currentGame
        
        }
        set(game) {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let game = game {
                let data = try! NSJSONSerialization.dataWithJSONObject((game.dictionary)!, options: [])
                defaults.setObject(data, forKey: "currentGameData")
                
            } else {
                defaults.setObject(nil, forKey: "currentGameData")
            }
            defaults.synchronize()
            
        }
    }

}
