//
//  TimerConstants.swift
//  Mafia
//
//  Created by Charles Yeh on 3/21/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class TimerConstants: NSObject {
    // role reveal view controller
    static let PRE_ROLE_REVEAL = 5.0
    // role reveal must spend exactly this amount of time:
    static let TOTAL_ROLE_REVEAL = 10.0
    
    // night overlay = 30.0
    static let GO_TO_SLEEP = 7.0
    static let MAFIA_WAKE_UP = 5.0
    static let MAFIA_NIGHTKILL = 10.0
    static let MAFIA_SLEEP = 6.0
    static let EVERYONE_WAKE_UP = 2.0
    
    static let NIGHT_OVERLAY_TIMERS = [GO_TO_SLEEP, MAFIA_WAKE_UP, MAFIA_NIGHTKILL, MAFIA_SLEEP, EVERYONE_WAKE_UP]
    
    // round end
}
