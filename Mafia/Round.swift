//
//  Round.swift
//  Mafia
//
//  Created by Charles Yeh on 3/7/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class Round: NSObject {
    
    var playerIds: [Int]?
    var lynches: [String: String]?
    var lynchedPlayerId: Int?
    var kills: [String: String]?
    var killedPlayerId: Int?
    
    var createdAt: NSDate?
    var expiresAt: NSDate?
    
    init(fromDictionary dictionary: NSDictionary) {
        playerIds = (dictionary["player_ids"] as! NSArray).map { id in
            return id as! Int
        }
        
        //lynches = (dictionary["lynches"] as! NSArray)
        lynchedPlayerId = dictionary["lynched_player_id"] as? Int
        
        //kills = dictionary["kills"]
        killedPlayerId = dictionary["killed_player_id"] as? Int
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        createdAt = formatter.dateFromString(dictionary["created_at"] as! String)
        expiresAt = formatter.dateFromString(dictionary["expires_at"] as! String)
    }
}
