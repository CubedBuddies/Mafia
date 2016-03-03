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
    var avatarType: Int = 0
    
    var createdAt: Int = 0
    var updatedAt: Int = 0
    
    init(fromResponse response: AnyObject) {
        
        let data = response as! NSDictionary
        id = data["id"] as! Int
        name = data["id"] as! String
        role = data["id"] as! String
        avatarType = data["id"] as! Int
        
        createdAt = data["id"] as! Int
        updatedAt = data["id"] as! Int
        
    }
}
