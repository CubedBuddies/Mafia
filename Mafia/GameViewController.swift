//
//  GameViewController.swift
//  Mafia
//
//  Created by Charles Yeh on 2/29/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playersCollectionView: UICollectionView!
    
    var lastEventOffset: Int = 0
    var updateTimer: NSTimer?
    
    var playerStates: [PlayerState]! {
        didSet {
            playerStatesMap = [Int: PlayerState]()
            for playerState in playerStates {
                playerStatesMap[playerState.id] = playerState
            }
        }
    }
    
    // mapping used to update players by id
    var playerStatesMap: [Int: PlayerState]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateTimer = NSTimer(timeInterval: 0.5, target: self, selector: "update", userInfo: nil, repeats: true)
        
        let playersDataSource = PlayersCollectionViewDataSource(view: playersCollectionView)
        playersCollectionView.delegate = playersDataSource
        playersCollectionView.dataSource = playersDataSource
    }

    override func viewWillDisappear(animated: Bool) {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func update() {
        // TODO: fetch events,
        MafiaClient.instance.getGameEvents { (events: [Event]) in
            let sortedEvents = events.sort { (event1: Event, event2: Event) in
                return event1.id < event2.id
            }
            
            for event in sortedEvents {
                if self.lastEventOffset <= event.id {
                    self.lastEventOffset = event.id
                    self.playEvent(event)
                }
            }
        }
    }
    
    func playEvent(event: Event) {
        let sourcePlayer = playerStatesMap[event.sourceId]
        let targetPlayer = playerStatesMap[event.targetId]
        
        switch event.name! {
        case .LYNCH:
            if let previousPlayer = playerStatesMap[sourcePlayer?.voteTargetId ?? 0] {
                previousPlayer.currentVotes -= 1
            }
            
            targetPlayer?.currentVotes += 1
            sourcePlayer?.voteTargetId = event.targetId
            
        case .UNLYNCH:
            assert(sourcePlayer?.voteTargetId != nil)
            targetPlayer?.currentVotes -= 1
            sourcePlayer?.voteTargetId = nil
            
        case .KILL:
            if let previousPlayer = playerStatesMap[sourcePlayer?.voteTargetId ?? 0] {
                previousPlayer.killVotes -= 1
            }
            
            targetPlayer?.killVotes += 1
            sourcePlayer?.killTargetId = event.targetId
            
        case .UNKILL:
            assert(sourcePlayer?.killTargetId != nil)
            targetPlayer?.killVotes -= 1
            sourcePlayer?.killTargetId = nil
            
        default:
            NSLog("Failed to play event.")
        }
        
        updatePlayerUI()
    }
    
    func updatePlayerUI() {
        // TODO: make this update single players at a time
        playersCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
