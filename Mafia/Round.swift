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
    var lynchVotes: [Int: Int]?
    var lynchedPlayerId: Int?
    var killVotes: [Int: Int]?
    var killedPlayerId: Int?
    
    var createdAt: NSDate?
    var expiresAt: NSDate?
    
    init(fromDictionary dictionary: NSDictionary) {
        playerIds = (dictionary["player_ids"] as! NSArray).map { id in
            return id as! Int
        }
        
        lynchVotes = [Int: Int]()
        for (key, value) in dictionary["lynch_votes"] as! NSDictionary {
            lynchVotes![key.integerValue] = value as? Int
        }
        lynchedPlayerId = dictionary["lynched_player_id"] as? Int
        
        killVotes = [Int: Int]()
        for (key, value) in dictionary["kill_votes"] as! NSDictionary {
            killVotes![key.integerValue] = value as? Int
        }
        killedPlayerId = dictionary["killed_player_id"] as? Int
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        createdAt = formatter.dateFromString(dictionary["created_at"] as! String)
        expiresAt = formatter.dateFromString(dictionary["expires_at"] as! String)
    }
}
