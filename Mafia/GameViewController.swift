//
//  GameViewController.swift
//  Mafia
//
//  Created by Charles Yeh on 2/29/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

protocol GameViewControllerDelegate {
    func getRoleMode() -> Bool
    
    func selectPlayer(targetPlayerId: Int)
}

class GameViewController: UIViewController, GameViewControllerDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, RoundEndViewDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playersCollectionView: UICollectionView!
    
    @IBOutlet weak var gameEndView: UIView! //RoundEndView that shows up in the GameViewController, not night mode

    var playersDataSource: PlayersCollectionViewDataSource?
    var updateTimer: NSTimer = NSTimer()
    var nightTimer: NSTimer = NSTimer()
    var nightIndex: Int = 0

    var roundIndex = 0
    var nightView: NightOverlayView?
    var roundEndView: RoundEndView?
    
    // whether they're viewing their role or not
    var roleMode = false
    
    // used to cache the player vote (for responsiveness)
    var pendingEventType: EventType?
    var pendingVote: Int?
    
    var isPresenting: Bool = true
    var interactiveTransition: UIPercentDrivenInteractiveTransition!
    
    var didPlayLullaby: Bool = false
    var didPlayRooster: Bool = false
    var didPlayClock: Bool = false
    
    var roosterAudioPlayer: AVAudioPlayer!
    var clockAudioPlayer: AVAudioPlayer!
    var lullabyAudioPlayer: AVAudioPlayer!
    
    //MARK: Display methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let roosterSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Rooster", ofType: "mp3")!)
            roosterAudioPlayer = try AVAudioPlayer(contentsOfURL: roosterSoundURL)
            roosterAudioPlayer.prepareToPlay()
            
            let clockSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Clock", ofType: "mp3")!)
            clockAudioPlayer = try AVAudioPlayer(contentsOfURL: clockSoundURL)
            clockAudioPlayer.prepareToPlay()
            
            let lullabySoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Lullaby", ofType: "mp3")!)
            lullabyAudioPlayer = try AVAudioPlayer(contentsOfURL: lullabySoundURL)
            lullabyAudioPlayer.prepareToPlay()
        } catch {
            print("Unable to load a sound")
        }
        
        // to show mafia voting
        roleMode = true
        showPlayerStats()
        dispatch_async(dispatch_get_main_queue()) {
            // start at night
            self.nightView = NightOverlayView.instanceFromNib()
            self.view.addSubview(self.nightView!)
            self.nightView!.frame = (self.nightView?.superview?.bounds)!
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateHandler", userInfo: nil, repeats: true)

        }
        
        // to make the screen slide in from the right
        modalPresentationStyle = UIModalPresentationStyle.Custom
        transitioningDelegate = self
        
        // create players data source
        playersDataSource = PlayersCollectionViewDataSource(view: self.playersCollectionView, showVotes: true, playerFilter: nil)
    
        playersDataSource!.delegate = self
        playersCollectionView.delegate = playersDataSource
        playersCollectionView.dataSource = playersDataSource
        
        resetTimer(TimerConstants.GO_TO_SLEEP)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateNightEvents()
    }
    
    func showPlayerStats() {
        if let player = MafiaClient.instance.player {
            if player.state == .DEAD {
                actionLabel.text = "You are dead :("
            } else {
                if roleMode {
                    avatarImageView.image = player.getRoleImage()
                    if let role = player.role {
                        nameLabel.text = role.rawValue
                        switch role {
                        case .TOWNSPERSON:
                            actionLabel.text = "Tap to Vote"
                        case .MAFIA:
                            actionLabel.text = "Tap to Kill"
                        }
                    }
                } else {
                    avatarImageView.setImageWithURL(player.getAvatarUrl(), placeholderImage: player.getPlaceholderAvatar())
                    nameLabel.text = player.name
                    actionLabel.text = "Tap to Vote"
                }
            }
            
        }
    }
    
    func showRoundEndView() {
        roundEndView = RoundEndView.instanceFromNib()
        roundEndView?.delegate = self
        
        let game = MafiaClient.instance.game!
        
        var playerNames = [Int: Player]()
        for player in game.players {
            playerNames[player.id] = player
        }
        
        
        if nightView!.hidden {
            // day round ended
            gameEndView.addSubview(self.roundEndView!)
            gameEndView.hidden = false
        } else {
            nightView!.resultsView.addSubview(self.roundEndView!)
            nightView!.resultsView.hidden = false
        }
        
        let currentRound = game.rounds[roundIndex]
        
        if game.state != .FINISHED {
            roundEndView?.descriptionBottomConstraint.constant = 0
            roundEndView?.descriptionTopConstraint.constant = 0
            
            // describe what happened
            if nightView!.hidden {
                // day round ended
                
                if let lynchedPlayerId = currentRound.lynchedPlayerId {
                    let player = playerNames[lynchedPlayerId]!
                    roundEndView?.endTitleLabel.text = "\(player.name) was lynched."
                    roundEndView?.endDescriptionLabel.text = "\(player.name) was \(player.role!)"
                    roundEndView?.deadPlayerImage.setImageWithURL(player.getAvatarUrl(), placeholderImage: player.getPlaceholderAvatar())
                } else {
                    roundEndView?.endTitleLabel.text = "No one was lynched."
                    roundEndView?.endDescriptionLabel.hidden = true
                }
                
                roundEndView?.nextButton.setTitle("Enter the night", forState: .Normal)
                updateTimer.invalidate()
            } else {
                // night round ended
                
                if let killedPlayerId = currentRound.killedPlayerId {
                    let player = playerNames[killedPlayerId]!
                    roundEndView?.endTitleLabel.text = "\(player.name) was killed by the Mafia."
                    roundEndView?.endDescriptionLabel.text = "\(player.name) was \(player.role!)"
                    roundEndView?.deadPlayerImage.setImageWithURL(player.getAvatarUrl(), placeholderImage: player.getPlaceholderAvatar())
                } else {
                    // no deaths during night
                    roundEndView?.endTitleLabel.text = "Mafia failed to kill any players"
                    roundEndView?.endDescriptionLabel.hidden = true
                }
                
                roundEndView?.endTitleLabel.sizeToFit()
                roundEndView?.endDescriptionLabel.sizeToFit()
                roundEndView?.nextButton.setTitle("Start voting", forState: .Normal)
            }
        } else {
            if let lynchedPlayerId = currentRound.lynchedPlayerId {
                let player = playerNames[lynchedPlayerId]!
                roundEndView?.endDescriptionLabel.text = "\(player.name) was \(player.role!)"
                roundEndView?.endDescriptionLabel.hidden = false
                roundEndView?.deadPlayerImage.setImageWithURL(player.getAvatarUrl(), placeholderImage: player.getPlaceholderAvatar())
            } else if let killedPlayerId = currentRound.killedPlayerId {
                let player = playerNames[killedPlayerId]!
                roundEndView?.endDescriptionLabel.text = "\(player.name) was \(player.role!)"
                roundEndView?.endDescriptionLabel.hidden = false
                roundEndView?.deadPlayerImage.setImageWithURL(player.getAvatarUrl(), placeholderImage: player.getPlaceholderAvatar())
            } else {
                roundEndView?.endDescriptionLabel.hidden = true
            }

            switch game.winner! {
            case .MAFIA:
                roundEndView?.endTitleLabel.text = "Mafia wins!"
            case .TOWNSPERSON:
                roundEndView?.endTitleLabel.text = "Town wins!"
            }
            roundEndView?.nextButton.setTitle("Exit game", forState: .Normal)
        }
        
        roundEndView?.frame = (roundEndView?.superview?.bounds)!
    }

    
    @IBAction func onAvatarTap(sender: AnyObject) {
        roleMode = !roleMode
        dispatch_async(dispatch_get_main_queue()) {
            self.showPlayerStats()
            self.playersDataSource!.showPlayerStats()
        }
    }
    
    func continueFromRoundEnd(roundEndView: RoundEndView, nextButtonPressed value: Bool) {
        NSLog("Transitioning to new round, from round \(roundIndex)")
        
        if MafiaClient.instance.game?.state == .FINISHED {
            // game over, return to main menu
            dispatch_async(dispatch_get_main_queue()) {
                self.updateTimer.invalidate()
                MafiaClient.instance.game = nil
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.presentViewController(vc!, animated: true, completion: nil)
            }
        } else {
            if nightView!.hidden {
                // continue to night
                advanceToNight()
            } else {
                advanceToDay()
            }
        }
    }
    
    func advanceToNight() {
        dispatch_async(dispatch_get_main_queue()) {
            let vc = GameViewController()
            vc.roundIndex = (MafiaClient.instance.game?.rounds.count)! - 1
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func advanceToDay() {
        nightView?.hidden = true
        roundIndex = (MafiaClient.instance.game?.rounds.count)! - 1
    }
    
    func getRoleMode() -> Bool {
        return roleMode
    }
    
    //MARK: Player Action Methods
    func fakeVote(eventType: EventType, targetPlayerId: Int) {
        if let round = MafiaClient.instance.game?.rounds[self.roundIndex] {
            switch eventType {
            case .KILL:
                round.killVotes![MafiaClient.instance.player!.id] = targetPlayerId
            case .LYNCH:
                round.lynchVotes![MafiaClient.instance.player!.id] = targetPlayerId
            }
            
            pendingEventType = eventType
            pendingVote = targetPlayerId
        }
    }
    
    func selectPlayer(targetPlayerId: Int) {
        if let player = MafiaClient.instance.player {
            if player.state == .DEAD {
                return
            }
            
            let eventType: EventType = (roleMode && player.role == .MAFIA) ? .KILL : .LYNCH
            fakeVote(eventType, targetPlayerId: targetPlayerId)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.updatePlayerView(MafiaClient.instance.game!)
            }
            
            MafiaClient.instance.addGameEvent(eventType, targetPlayerId: targetPlayerId, completion: { _ in
                print(String(EventType) + " " + String(targetPlayerId))
                NSLog("Sent vote!")
                }, failure: { _ in
                    NSLog("Failed to select player")
            })
        }
    }
    
    //MARK: Update and Loading Methods
    func updateHandler() {
        MafiaClient.instance.pollGameStatus(
            completion: { (game: Game) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadRoundData(game)
                }
            },
            failure: { NSLog("Failed to poll game status") }
        )
    }
    
    func resetTimer(time: Double) {
        nightTimer.invalidate()
        nightTimer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("updateNightEvents"), userInfo: nil, repeats: false)
    }
    
    func updateNightEvents() {
        dispatch_async(dispatch_get_main_queue()) {
            // before each segment, update text / UI
            let nightView = self.nightView!
            
            switch self.nightIndex {
            case 0:
                nightView.dialogueLabel.text = "Everyone Go To Sleep..."
                if !self.didPlayLullaby {
                    self.didPlayLullaby = true
                    self.lullabyAudioPlayer.play()
                }
            case 1:
                nightView.dialogueLabel.text = "Mafia Wake Up"
                
                // TODO: vibrate phone if player is mafia
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                if !self.didPlayClock {
                    self.didPlayClock = true
                    self.clockAudioPlayer.play()
                }
            case 2:
                if MafiaClient.instance.player?.role == .MAFIA {
                    self.showPlayerStats()
                    self.updatePlayerView(MafiaClient.instance.game!)
                    nightView.hidden = true
                }
            case 3:
                nightView.hidden = false
                nightView.dialogueLabel.text = "Mafia Go Back to Sleep"
            case 4:
                nightView.dialogueLabel.text = "Everyone Wake Up!"
                nightView.imageView.image = UIImage(named: "sunrise")
                
                // vibrate phone for all players
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                if !self.didPlayRooster {
                    self.didPlayRooster = true
                    self.roosterAudioPlayer.play()
                }
            case 5:
                // night round end will be shown when new round is loaded
                break
            case 6:
                // mafia have finished voting
                self.roleMode = false
                return
            default:
                NSLog("Error, invalid night event index.")
            }
            
            nightView.dialogueLabel.sizeToFit()
            self.resetTimer(TimerConstants.NIGHT_OVERLAY_TIMERS[self.nightIndex])
            
            self.nightIndex += 1
        }
    }
    
    func loadRoundData(game: Game) {
        if game.state == .FINISHED {
            showRoundEndView()
        } else {
            if pendingVote != nil {
                fakeVote(self.pendingEventType!, targetPlayerId: self.pendingVote!)
                
                if self.pendingVote != nil {
                    self.pendingEventType = nil
                    self.pendingVote = nil
                }
            }
            
            if roundIndex < (game.rounds.count ?? 1) - 1 {
                showRoundEndView()
            } else {
                let round = game.rounds[self.roundIndex]
                let secondsLeft = Int(round.expiresAt!.timeIntervalSinceDate(NSDate(timeIntervalSinceNow: 0)))
                
                timerLabel.text = "00:\(String(format: "%02d", secondsLeft))"
                
                showPlayerStats()
                updatePlayerView(game)
            }
        }
    }
    
    func updatePlayerView(game: Game) {
        self.playersDataSource?.round = game.rounds[game.rounds.count - 1]
        self.playersDataSource?.game = game
        
        self.playersCollectionView.reloadData()
    }
    
    
    //MARK: transitions and animations
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        containerView.addSubview(toViewController.view)
        
        let destRect = fromViewController.view.frame
        toViewController.view.frame = CGRectOffset(destRect, destRect.size.width, 0)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            toViewController.view.frame = destRect
        }) { (finished: Bool) -> Void in
        }
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            fromViewController.view.alpha = 0
            }) { (finished: Bool) -> Void in
                transitionContext.completeTransition(true)
                fromViewController.view.removeFromSuperview()
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
