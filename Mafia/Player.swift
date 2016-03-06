//
//  Player.swift
//  Mafia
//
//  Created by Charles Yeh on 3/3/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class Player: NSObject {
    
    var id: Int = 0
    var name: String = ""
    var role: String = ""
    var isGameCreator: Bool?
    var avatarType: Int = 0
    
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    var dictionary: NSDictionary?
    
    init(fromResponse response: AnyObject) {
        let data = response as! NSDictionary
        
        self.dictionary = data
        
        id = data["id"] as! Int
        isGameCreator = data["is_game_creator"] as? Bool
        name = data["name"] as! String
        role = data["role"] as! String
        avatarType = data["avatar_type"] as! Int
        
        createdAt = data["created_at"] as? NSDate
        updatedAt = data["updated_at"] as? NSDate
    }
    
    static var _currentPlayer: Player?
    class var currentPlayer: Player? {
        get {
            if _currentPlayer == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let playerData = defaults.objectForKey("currentPlayerData") as? NSData
                if let playerData = playerData {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(playerData, options: []) as! NSDictionary
                    _currentPlayer = Player(fromResponse: dictionary)
                }
            }
            return _currentPlayer
        
        }
        set(player) {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let player = player {
                let data = try! NSJSONSerialization.dataWithJSONObject((player.dictionary)!, options: [])
                defaults.setObject(data, forKey: "currentPlayerData")
  
            } else {
                defaults.setObject(nil, forKey: "currentPlayerData")
            }
            defaults.synchronize()
            
        }
    }
}
