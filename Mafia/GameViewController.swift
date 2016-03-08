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
    
    var players: [Player]! {
        didSet {
            // TODO
            /*playerStatesMap = [Int: PlayerState]()
            for playerState in playerStates {
                playerStatesMap[playerState.name] = playerState
            }*/
        }
    }
    
    // mapping used to update players by id
    var playerStatesMap: [Int: PlayerState]!
    var playersDataSource: PlayersCollectionViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        playersDataSource = PlayersCollectionViewDataSource(view: playersCollectionView)
        playersCollectionView.registerNib(UINib(nibName: "PlayersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "playerCell")
        
        playersCollectionView.delegate = playersDataSource
        playersCollectionView.dataSource = playersDataSource
    }

    override func viewWillDisappear(animated: Bool) {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func update() {
        MafiaClient.instance.pollGameStatus { (game: Game) in
            self.playersDataSource?.playerStates = game.players
            self.playersCollectionView.reloadData()
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
