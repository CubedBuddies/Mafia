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
    var role: String? = ""
    var state: String? = ""
    var isGameCreator: Bool?
    var avatarType: String = ""
    
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    var dictionary: NSDictionary?
    
    init(fromResponse response: AnyObject) {
        super.init()
        
        let data = response as! NSDictionary
        dictionary = data
        
        if let player = data["player"] as? NSDictionary {
            setValues(player)
        }
    }
    
    init(fromDictionary dictionary: NSDictionary) {
        super.init()
        setValues(dictionary)
    }
    
    func setValues(dictionary: NSDictionary) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        
        role = dictionary["role"] as? String
        state = dictionary["state"] as? String
        
        avatarType = dictionary["avatar_type"] as! String
        
        createdAt = dictionary["created_at"] as? NSDate
        updatedAt = dictionary["updated_at"] as? NSDate
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
