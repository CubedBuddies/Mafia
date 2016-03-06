//
//  Game.swift
//  Mafia
//
//  Created by Charles Yeh on 3/3/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class Game: NSObject {
    
    var id: Int = 0
    var token: String = ""
    var status: String = ""
    var players: [Player] = []
    
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    var dictionary: NSDictionary?
    
    init(fromResponse response: AnyObject) {
        
        let data = response as! NSDictionary
        
        self.dictionary = data
        
        id = data["id"] as! Int
        token = data["token"] as! String
        status = data["status"] as! String
        players = (data["player"] as! NSArray).map { (playerResponse) -> Player in
            Player(fromResponse: playerResponse)
        }
        
        createdAt = data["created_at"] as? NSDate
        updatedAt = data["updated_at"] as? NSDate
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
