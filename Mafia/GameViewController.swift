//
//  GameViewController.swift
//  Mafia
//
//  Created by Charles Yeh on 2/29/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

protocol GameViewControllerDelegate {
    func selectPlayer(targetPlayerId: Int)
}

class GameViewController: UIViewController, GameViewControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playersCollectionView: UICollectionView!

    // round end screen
    @IBOutlet weak var roundEndView: UIView!
    @IBOutlet weak var endTitleLabel: UILabel!
    @IBOutlet weak var endDescriptionLabel: UILabel!
    @IBOutlet weak var endRoundContinueButton: UIButton!
    
    var playersDataSource: PlayersCollectionViewDataSource?
    var updateTimer: NSTimer = NSTimer()

    var roundIndex = 0
    var time: Int = 0
    
    // whether they're viewing their role or not
    var roleMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dispatch_async(dispatch_get_main_queue()) {
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateHandler"), userInfo: nil, repeats: true)
            
            self.showPlayerStats()
            self.roundEndView.hidden = true
        }

        time = 5 * 60

        playersDataSource = PlayersCollectionViewDataSource(view: playersCollectionView)
        playersDataSource!.delegate = self
        playersCollectionView.registerNib(UINib(nibName: "PlayersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "playerCell")

        playersCollectionView.delegate = playersDataSource
        playersCollectionView.dataSource = playersDataSource
    }
    
    @IBAction func onAvatarTap(sender: AnyObject) {
        roleMode = !roleMode
        dispatch_async(dispatch_get_main_queue()) {
            self.showPlayerStats()
        }
    }
    
    func showPlayerStats() {
        if let player = MafiaClient.instance.player {
            if roleMode {
                if let role = player.role {
                    nameLabel.text = role.rawValue
                    switch role {
                    case .TOWNSPERSON:
                        avatarImageView.image = UIImage(named: player.avatarType)
                        actionLabel.text = ""
                    case .MAFIA:
                        avatarImageView.image = UIImage(named: "mafia")
                        actionLabel.text = "TAP TO KILL"
                    }
                }
            } else {
                avatarImageView.image = UIImage(named: player.avatarType)
                nameLabel.text = player.name
                actionLabel.text = "Tap to Vote"
            }
        }
    }
    
    func showRoundEndView() {
        roundEndView.hidden = false
        endScreen()
        
        if let game = MafiaClient.instance.game {
            var playerNames = [Int: String]()
            for player in game.players {
                playerNames[player.id] = player.name
            }
            
            if game.state == .FINISHED {
                switch game.winner! {
                case .MAFIA:
                    endTitleLabel.text = "Mafia wins!"
                case .TOWNSPERSON:
                    endTitleLabel.text = "Town wins!"
                }
                
                endRoundContinueButton.titleLabel?.text = "Exit game"
            } else {
                endTitleLabel.text = "Night sets..."
                let currentRound = game.rounds[roundIndex]
                
                var descriptionSegments = [String]()
                if let lynchedPlayerId = currentRound.lynchedPlayerId {
                    descriptionSegments.append("\(playerNames[lynchedPlayerId]!) was lynched!")
                }
                if let killedPlayerId = currentRound.killedPlayerId {
                    descriptionSegments.append("\(playerNames[killedPlayerId]!) was killed by the mafia!")
                }
                endDescriptionLabel.text = descriptionSegments.joinWithSeparator("\n")
            }
        }
        
    }

    @IBAction func onContinueToNextRound(sender: AnyObject) {
        NSLog("Transitioning to new round, from round \(roundIndex)")
        
        let vc = GameViewController()
        vc.roundIndex = roundIndex + 1
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func updateHandler() {
        MafiaClient.instance.pollGameStatus(
            completion: { (game: Game) in
                dispatch_async(dispatch_get_main_queue()) {
                    if game.state == .FINISHED {
                        self.showRoundEndView()
                    } else {
                        self.loadRoundData(game)
                    }
                }
            },
            failure: { NSLog("Failed to poll game status") }
        )
    }
    
    func loadRoundData(game: Game) {
        if self.roundIndex < (game.rounds.count ?? 1) - 1 {
            // round is over, no point pulling data
            showRoundEndView()
        } else {
            let round = game.rounds[self.roundIndex]
            let secondsLeft = Int(round.expiresAt!.timeIntervalSinceDate(NSDate(timeIntervalSinceNow: 0)))
            self.timerLabel.text = "\(secondsLeft)"
            
            for player in game.players {
                if player.id == MafiaClient.instance.player!.id {
                    MafiaClient.instance.player = player
                    self.showPlayerStats()
                    break
                }
            }
            
            if game.rounds.count > 0 {
                self.playersDataSource?.round = game.rounds[game.rounds.count - 1]
            }
            
            self.playersDataSource?.game = game
            self.playersCollectionView.reloadData()
        }
    }

    func selectPlayer(targetPlayerId: Int) {
        let eventType: EventType = (roleMode && MafiaClient.instance.player?.role == .MAFIA) ? .KILL : .LYNCH
        MafiaClient.instance.addGameEvent(eventType, targetPlayerId: targetPlayerId, completion: { _ in
            // TODO: successfully sent event
            NSLog("Sent vote!")
        }, failure: { _ in
            NSLog("Failed to select player")
        })
    }
    
    func endScreen() {
        NSLog("Clearing game screen")
        updateTimer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
