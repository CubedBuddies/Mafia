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
    
    var createdAt: Int = 0
    var updatedAt: Int = 0
    
    init(fromResponse response: AnyObject) {
        
        let data = response as! NSDictionary
        id = data["id"] as! Int
        token = data["id"] as! String
        status = data["id"] as! String
        players = (data["id"] as! NSArray).map { (playerResponse) -> Player in
            Player(fromResponse: playerResponse)
        }
        
        createdAt = data["id"] as! Int
        updatedAt = data["id"] as! Int
        
    }
}
