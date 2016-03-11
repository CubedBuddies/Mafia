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
    var state: PlayerState? = .ALIVE
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
        state = PlayerState(rawValue: dictionary["state"] as? String ?? PlayerState.ALIVE.rawValue)
        
        avatarType = dictionary["avatar_type"] as! String
        
        createdAt = dictionary["created_at"] as? NSDate
        updatedAt = dictionary["updated_at"] as? NSDate
    }
}

enum PlayerState: String {
    case DEAD = "dead"
    case ALIVE = "alive"
}
