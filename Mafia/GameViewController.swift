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
        
        self.roleMode = true
        
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
        
        // Do any additional setup after loading the view.
        dispatch_async(dispatch_get_main_queue()) {
            self.nightView = NightOverlayView.instanceFromNib()
            self.view.addSubview(self.nightView!)
            self.nightView!.frame = (self.nightView?.superview?.bounds)!
            
            self.showPlayerStats()
            
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateHandler"), userInfo: nil, repeats: true)
        }
        
        modalPresentationStyle = UIModalPresentationStyle.Custom
        transitioningDelegate = self

        playersDataSource = PlayersCollectionViewDataSource(view: playersCollectionView, showVotes: true, playerFilter: nil)
        playersDataSource!.delegate = self
        
        playersCollectionView.delegate = playersDataSource
        playersCollectionView.dataSource = playersDataSource
        
        loadRoundData(MafiaClient.instance.game!)
        
        resetTimer(TimerConstants.GO_TO_SLEEP)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateNightEvents()
        
        if MafiaClient.instance.game!.state == .FINISHED {
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(false, completion: nil)
            }
        }
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
        updateTimer.invalidate()
        
        self.roundEndView = RoundEndView.instanceFromNib()
        self.roundEndView?.delegate = self
        
        if nightView!.hidden {
            // ended during day
            gameEndView.addSubview(self.roundEndView!)
            gameEndView.hidden = false
        } else {
            // ended during night
            nightView!.resultsView.addSubview(self.roundEndView!)
            nightView!.resultsView.hidden = false
        }
        
        self.roundEndView!.frame = (self.roundEndView?.superview?.bounds)!
        
        if let game = MafiaClient.instance.game {
            var playerNames = [Int: Player]()
            for player in game.players {
                playerNames[player.id] = player
            }
            
            if game.state != .FINISHED {
                
                let currentRound = game.rounds[roundIndex]
                if MafiaClient.instance.isNight {
                    roundEndView?.nextButton.setTitle("Vote", forState: .Normal)
                    self.roundEndView?.endTitleLabel.hidden = false
                    self.roundEndView?.endDescriptionLabel.hidden = true
                    if let killedPlayerId = currentRound.killedPlayerId {
                        let player = playerNames[killedPlayerId]!
                        self.roundEndView?.endTitleLabel.text = "\(player.name) was killed by the Mafia."
                    } else {
                        self.roundEndView?.endTitleLabel.text = "Mafia failed to kill any players"
                    }
                } else if let lynchedPlayerId = currentRound.lynchedPlayerId {
                    let player = playerNames[lynchedPlayerId]!
                    self.roundEndView?.endTitleLabel.text = "\(player.name) was lynched."
                    self.roundEndView?.endDescriptionLabel.text = "\(player.name) was \(player.role!)"
                    roundEndView?.nextButton.setTitle("Start Next Round", forState: .Normal)
                }
                
                MafiaClient.instance.isNight = !MafiaClient.instance.isNight
            } else {
                switch game.winner! {
                case .MAFIA:
                    roundEndView?.endTitleLabel.text = "Mafia wins!"
                case .TOWNSPERSON:
                    roundEndView?.endTitleLabel.text = "Town wins!"
                }
                
                roundEndView?.endDescriptionLabel.hidden = true
                roundEndView?.nextButton.setTitle("Exit game", forState: .Normal)
            }
        }
    }

    
    @IBAction func onAvatarTap(sender: AnyObject) {
        roleMode = !roleMode
        dispatch_async(dispatch_get_main_queue()) {
            self.showPlayerStats()
            self.playersDataSource!.showPlayerStats()
        }
    }
    
    func roundEndView(roundEndView: RoundEndView, nextButtonPressed value: Bool) {
        NSLog("Transitioning to new round, from round \(roundIndex)")
        
        if MafiaClient.instance.game?.state == .FINISHED {
            dispatch_async(dispatch_get_main_queue()) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                self.presentViewController(vc!, animated: true, completion: nil)
            }
        } else {
            let vc = GameViewController()
            vc.roundIndex = (MafiaClient.instance.game?.rounds.count)!-1
            
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
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
        if pendingVote != nil {
            pendingEventType = nil
            pendingVote = nil
        }
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
        nightTimer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "updateNightEvents", userInfo: nil, repeats: false)
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
                nightView.dialogueLabel.text = "Everyone Wake Up\n\nDiscuss!"
                nightView.imageView.image = UIImage(named: "sunrise")
                
                // vibrate phone for all players
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                if !self.didPlayRooster {
                    self.didPlayRooster = true
                    self.roosterAudioPlayer.play()
                }
            case 5:
                nightView.hidden = true
                
                // Reset all sounds
                self.didPlayLullaby = false
                self.didPlayClock = false
                self.didPlayRooster = false
                return
            default:
                NSLog("Error, invalid night event index.")
            }
            
            nightView.dialogueLabel.sizeToFit()
            self.resetTimer(TimerConstants.NIGHT_OVERLAY_TIMERS[self.nightIndex])
            
            self.nightIndex++
        }
    }
    
    func loadRoundData(game: Game) {
        
        if game.state == .FINISHED {
            showRoundEndView()
        } else {
            if pendingVote != nil {
                fakeVote(self.pendingEventType!, targetPlayerId: self.pendingVote!)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
