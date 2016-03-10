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
    
    var playersDataSource: PlayersCollectionViewDataSource?
    
    var roundIndex = 0
    var time: Int = 0
    var lastEventOffset: Int = 0
    var updateTimer: NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dispatch_async(dispatch_get_main_queue()) {
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateHandler"), userInfo: nil, repeats: true)
        }
        
        time = 5 * 60
        roundIndex = 0
        
        playersDataSource = PlayersCollectionViewDataSource(view: playersCollectionView)
        playersDataSource!.delegate = self
        playersCollectionView.registerNib(UINib(nibName: "PlayersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "playerCell")
        
        playersCollectionView.delegate = playersDataSource
        playersCollectionView.dataSource = playersDataSource
        
    }

    override func viewWillDisappear(animated: Bool) {
        endScreen()
    }
    
    func endScreen() {
        NSLog("Clearing game screen")
        updateTimer.invalidate()
    }
    
    func updateHandler() {
        timerLabel.text = "\(time--)"
        MafiaClient.instance.pollGameStatus { (game: Game) in
            dispatch_async(dispatch_get_main_queue()) {
                
                if self.roundIndex < (game.rounds?.count ?? 1) - 1 {
                    self.roundIndex = game.rounds!.count - 1
                    self.transitionToNewRound()
                } else {
                    if let rounds = game.rounds {
                        if game.rounds?.count > 0 {
                            self.playersDataSource?.round = rounds[rounds.count - 1]
                        }
                    }
                    self.playersDataSource?.game = game
                    self.playersCollectionView.reloadData()
                }
            }
        }
    }
    
    func transitionToNewRound() {
        let vc = GameViewController()
        vc.view.layoutIfNeeded()
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func selectPlayer(targetPlayerId: Int) {
        MafiaClient.instance.addGameEvent("vote", targetPlayerId: targetPlayerId) { _ in
            // TODO: successfully sent event
            NSLog("Sent vote!")
        }
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
