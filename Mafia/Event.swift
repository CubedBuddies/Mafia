//
//  Event.swift
//  Mafia
//
//  Created by Charles Yeh on 3/3/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class Event: NSObject {
    
    var id: Int = 0
    var name: EventType!
    
    var sourceId: Int = 0
    var targetId: Int = 0
    
    var createdAt: Int = 0
    var updatedAt: Int = 0
    
    init(fromResponse response: AnyObject) {
        
        let data = response as! NSDictionary
        if let event = data["event"] as? NSDictionary {
            
            name = EventType.fromRawString(event["name"] as! String)
            targetId = event["target_player_id"] as! Int
            sourceId = event["source_player_id"] as! Int
        }
    }
}

enum EventType {
    case LYNCH, UNLYNCH, KILL, UNKILL, VOTE, UNVOTE
    
    static func fromRawString(rawString: String) -> EventType? {
        switch rawString {
        case "LYNCH":
            return .LYNCH
        case "UNLYNCH":
            return .UNLYNCH
        case "KILL":
            return .KILL
        case "UNKILL":
            return .UNKILL
        default:
            return nil
        }
    }
}
