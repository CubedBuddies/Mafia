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
    var sourceType: String = ""
    
    var targetId: Int = 0
    var targetType: String = ""
    
    var createdAt: Int = 0
    var updatedAt: Int = 0
    
    init(fromResponse response: AnyObject) {
        
        let data = response as! NSDictionary
        id = data["id"] as! Int
        
        name = EventType.fromRawString(data["id"] as! String)
        targetId = data["id"] as! Int
        targetType = data["id"] as! String
        
        createdAt = data["id"] as! Int
        updatedAt = data["id"] as! Int
        
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
