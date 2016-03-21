//
//  GameViewController.swift
//  Mafia
//
//  Created by Charles Yeh on 2/29/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit
import AudioToolbox

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
    
    //MARK: Display methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print(MafiaClient.instance.game?.createdAt)
        // Do any additional setup after loading the view.
        dispatch_async(dispatch_get_main_queue()) {
            if MafiaClient.instance.isNight == true{
                self.roleMode = true
                self.nightTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateNightEvents"), userInfo: nil, repeats: true)
                self.nightView = NightOverlayView.instanceFromNib() 
                self.view.addSubview(self.nightView!)
                self.nightView!.frame = (self.nightView?.superview?.bounds)!
            } else {
                self.showPlayerStats()
            }
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateHandler"), userInfo: nil, repeats: true)
        }
        
        modalPresentationStyle = UIModalPresentationStyle.Custom
        transitioningDelegate = self

        playersDataSource = PlayersCollectionViewDataSource(view: playersCollectionView, showVotes: true, playerFilter: nil)
        playersDataSource!.delegate = self
        
        playersCollectionView.delegate = playersDataSource
        playersCollectionView.dataSource = playersDataSource
        
        loadRoundData(MafiaClient.instance.game!)
    }
    
    override func viewWillAppear(animated: Bool) {
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
        endScreen()
        self.roundEndView = RoundEndView.instanceFromNib()
        self.roundEndView?.delegate = self
        if MafiaClient.instance.isNight {
            nightView?.resultsView.addSubview(self.roundEndView!)
            nightView?.resultsView.hidden = false
        } else {
            self.gameEndView.addSubview(self.roundEndView!)
            self.gameEndView.hidden = false
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
    
    func endScreen() {
        NSLog("Clearing game screen")
        updateTimer.invalidate()
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
                    if game.state == .FINISHED {
                        self.showRoundEndView()
                        print ("jalskjdfklsa;ds")
                    } else {self
                        if self.pendingVote != nil {
                            self.fakeVote(self.pendingEventType!, targetPlayerId: self.pendingVote!)
                        }
                        self.loadRoundData(game)
                    }
                }
            },
            failure: { NSLog("Failed to poll game status") }
        )
    }
    
    func updateNightEvents() {
        loadRoundData(MafiaClient.instance.game!)
    }
    
    func loadRoundData(game: Game) {
        print("round index is: " + String(self.roundIndex) + " game count is: " + String(game.rounds.count))
        if self.roundIndex < (game.rounds.count ?? 1) - 1 {
            // round is over, no point pulling data
            showRoundEndView()
            print("poopypants")
        } else {
            let round = game.rounds[self.roundIndex]
            let secondsLeft = Int(round.expiresAt!.timeIntervalSinceDate(NSDate(timeIntervalSinceNow: 0)))
            MafiaClient.instance.player?.role = .MAFIA
            if MafiaClient.instance.isNight == true {
                nightView?.timeLabel.text = "00:\(String(format: "%02d", secondsLeft))"
                if secondsLeft > 20 {
                    nightView?.dialogueLabel.text = "Everyone Go To Sleep...\n\nWait for Phone Vibration to Wake Up"
                    nightView?.dialogueLabel.sizeToFit()
                } else if secondsLeft > 18 && secondsLeft < 20 {
                    //vibrate phone if player is mafia
                    nightView?.dialogueLabel.text = "Mafia Wake Up"
                    nightView?.dialogueLabel.sizeToFit()
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                } else if secondsLeft < 18 && secondsLeft > 8{
                    if MafiaClient.instance.player?.role == .MAFIA {
                        showPlayerStats()
                        updatePlayerView(game)
                        nightView?.hidden = true
                    }
                } else if secondsLeft < 8 && secondsLeft > 2 {
                    nightView?.hidden = false
                    nightView?.dialogueLabel.text = "Mafia Go Back to Sleep"
                    nightView?.dialogueLabel.sizeToFit()
                } else if secondsLeft > 0 && secondsLeft < 2 {
                    //vibrate phone for all players
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    nightView?.dialogueLabel.text = "Everyone Wake Up"
                    nightView?.dialogueLabel.sizeToFit()
                    nightView?.imageView.image = UIImage(named: "sunrise")
                } else if secondsLeft <= 0 {
                    nightView?.dialogueLabel.text = "Discuss!"
                    nightTimer.invalidate()
                }
            }
            self.timerLabel.text = "00:\(String(format: "%02d", secondsLeft))"
            showPlayerStats()
            updatePlayerView(game)
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
    
    
    /*
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        interactiveTransition = UIPercentDrivenInteractiveTransition()
        //Setting the completion speed gets rid of a weird bounce effect bug when transitions complete
        interactiveTransition.completionSpeed = 0.99
        return interactiveTransition
    }
    
    @IBAction func onPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let dx = translation.x
        if (sender.state == UIGestureRecognizerState.Began){
            dismissViewControllerAnimated(true, completion: nil)
        } else if (sender.state == UIGestureRecognizerState.Changed){
            interactiveTransition.updateInteractiveTransition(dx / view.frame.width)
        } else if sender.state == UIGestureRecognizerState.Ended {
            let velocity = sender.velocityInView(view).x
            if velocity > 0 {
                interactiveTransition.finishInteractiveTransition()
            } else {
                interactiveTransition.cancelInteractiveTransition()
            }
        }
    }*/
}
