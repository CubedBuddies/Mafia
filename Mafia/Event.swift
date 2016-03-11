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
            
            name = EventType(rawValue: event["name"] as! String)
            targetId = event["target_player_id"] as! Int
            sourceId = event["source_player_id"] as! Int
        }
    }
}

enum EventType: String {
    case LYNCH = "lynch"
    case KILL = "kill"
}
