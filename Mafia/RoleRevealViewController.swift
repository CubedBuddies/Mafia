//
//  RoleRevealViewController.swift
//  Mafia
//
//  Created by Priscilla Lok on 3/13/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit
import AFNetworking

class RoleRevealViewController: UIViewController {


    @IBOutlet weak var tapNotificationLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var roleView: UIView!
    @IBOutlet weak var roleDescriptionLabel: UILabel!
    @IBOutlet weak var teamCollectionView: UICollectionView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var roleImageView: UIImageView!
    
    var isBackShowing = true
    var mafiaCollectionViewDelegate: PlayersCollectionViewDataSource?
    
    var revealAdvanceTimer: NSTimer?
    var finalAdvanceTimer: NSTimer?
    var roleVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let player = MafiaClient.instance.player {
            self.avatarImageView.setImageWithURLRequest(NSURLRequest(URL: player.getAvatarUrl()), placeholderImage: player.getPlaceholderAvatar(), success: { (request, response, image) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.avatarImageView.image = image
                }
            }, failure: { (request, response, error) -> Void in
                print(error)
            })
            
            self.roleImageView.image = player.getRoleImage()
        }
        
        roleImageView.hidden = true
        roleDescriptionLabel.hidden = true
        nextButton.hidden = true
        
        roleView.layoutIfNeeded()
        roleView.bringSubviewToFront(tapNotificationLabel)
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapped"))
        singleTap.numberOfTapsRequired = 1
        roleView.addGestureRecognizer(singleTap)
        
        // show fellow mafia mates
        teamCollectionView.hidden = true
        mafiaCollectionViewDelegate = PlayersCollectionViewDataSource(view: teamCollectionView, showVotes: false) { (player: Player) -> Bool in
            
            return player.role == .MAFIA
        }
        
        teamCollectionView.delegate = mafiaCollectionViewDelegate
        teamCollectionView.dataSource = mafiaCollectionViewDelegate
        mafiaCollectionViewDelegate!.game = MafiaClient.instance.game
        
        revealAdvanceTimer = NSTimer.scheduledTimerWithTimeInterval(TimerConstants.PRE_ROLE_REVEAL, target: self, selector: "tapped", userInfo: nil, repeats: false)
        finalAdvanceTimer = NSTimer.scheduledTimerWithTimeInterval(TimerConstants.TOTAL_ROLE_REVEAL, target: self, selector: "showGame", userInfo: nil, repeats: false)
    }
    
    func revealRole() {
        if !roleVisible {
            tapped()
        } else {
            onNextButtonClicked(nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapped() {
        if isBackShowing {
            roleVisible = true
            revealAdvanceTimer?.invalidate()
            
            UIView.transitionFromView(avatarImageView, toView: roleImageView, duration: 1.0, options: [.TransitionFlipFromRight, .ShowHideTransitionViews], completion: nil)
            
            switch MafiaClient.instance.player!.role! {
            case .TOWNSPERSON:
                roleDescriptionLabel.text = "Figure out who the mafia is and lynch them during the day."
                
            case .MAFIA:
                dispatch_async(dispatch_get_main_queue()) {
                    self.roleDescriptionLabel.text = "Kill someone each night with your fellow mafia."
                    self.teamCollectionView.hidden = false
                    self.teamCollectionView.reloadData()
                }
            }
            roleDescriptionLabel.hidden = false
            nextButton.hidden = false
            
            tapNotificationLabel.hidden = true
            isBackShowing = false
        } else {
            UIView.transitionFromView(roleImageView, toView: avatarImageView, duration: 1.0, options: [.TransitionFlipFromRight, .ShowHideTransitionViews], completion: nil)
            tapNotificationLabel.hidden = false
            isBackShowing = true
        }
    }

    @IBAction func onNextButtonClicked(sender: AnyObject?) {
        nextButton.setTitle("Get ready...", forState: .Normal)
    }
    
    func showGame() {
        revealAdvanceTimer?.invalidate()
        finalAdvanceTimer?.invalidate()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(GameViewController(), animated: true, completion: nil)
        }
    }

}
