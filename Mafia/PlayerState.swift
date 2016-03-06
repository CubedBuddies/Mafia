//
//  PlayerState.swift
//  Mafia
//
//  Created by Charles Yeh on 3/5/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class PlayerState: Player {
    var voteTargetId: Int?
    var killTargetId: Int?
    
    // convenience counters for display
    var currentVotes: Int = 0
    var killVotes: Int = 0
}
