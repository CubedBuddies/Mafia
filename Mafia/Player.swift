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
    var role: PlayerRole?
    var state: PlayerState = .ALIVE
    var isGameCreator: Bool?
    var avatarUrl: String = ""
    
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    var dictionary: NSDictionary?
    
    init(playerName: String) {
        name = playerName
    }
    
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
        
        role = PlayerRole(rawValue: dictionary["role"] as? String ?? "")
        state = PlayerState(rawValue: dictionary["state"] as? String ?? PlayerState.ALIVE.rawValue)!

        avatarUrl = dictionary["avatar_url"] as! String
        
        createdAt = dictionary["created_at"] as? NSDate
        updatedAt = dictionary["updated_at"] as? NSDate
    }
    
    func getAvatarUrl() -> NSURL {
        return NSURL(string: MafiaClient.BASE_URL + avatarUrl)!
    }
    
    func getRoleImage() -> UIImage {
        if let role = role {
            switch role {
            case .MAFIA:
                return UIImage(named: "mafia")!
            case .TOWNSPERSON:
                // arbitrary hashing function
                let icons = ["boy1", "boy2", "girl1", "girl2"]
                return UIImage(named: icons[(id * 7) % 4])!
            }
        } else {
            return getPlaceholderAvatar()
        }
    }
    
    func getPlaceholderAvatar() -> UIImage {
        return UIImage(named: "Character_mystery_white")!
    }
}

enum PlayerRole: String {
    case TOWNSPERSON = "townsperson"
    case MAFIA = "mafia"
}

enum PlayerState: String {
    case DEAD = "dead"
    case ALIVE = "alive"
}
