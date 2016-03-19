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


    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var roleView: UIView!
    @IBOutlet weak var roleDescriptionLabel: UILabel!
    @IBOutlet weak var teamCollectionView: UICollectionView!
    
    var roleImageView: UIImageView!
    var avatarImageView: UIImageView!
    var isBackShowing = true
    var mafiaCollectionViewDelegate: PlayersCollectionViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let player = MafiaClient.instance.player {
            self.avatarImageView = UIImageView(image: player.getPlaceholderAvatar())
            self.avatarImageView.setImageWithURLRequest(NSURLRequest(URL: player.getAvatarUrl()), placeholderImage: nil, success: { (request, response, image) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.avatarImageView.image = image
                    self.avatarImageView.frame = self.roleImageView.frame
                }
                }, failure: { (request, response, error) -> Void in
                    
                    print(error)
                })
            
            self.roleImageView = UIImageView(image: player.getRoleImage())
        }
        
        // TODO: convert this to auto layout
        avatarImageView.center = CGPointMake(roleView.center.x, roleView.center.y-40)
        roleImageView.center = CGPointMake(roleView.center.x, roleView.center.y-40)
        
        roleView.addSubview(avatarImageView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapped"))
        singleTap.numberOfTapsRequired = 1
        
        roleDescriptionLabel.hidden = true
        roleView.addGestureRecognizer(singleTap)
        
        nextButton.hidden = true
        
        // show fellow mafia mates
        teamCollectionView.hidden = true
        mafiaCollectionViewDelegate = PlayersCollectionViewDataSource(view: teamCollectionView, showVotes: false) { (player: Player) -> Bool in
            
            return player.role == .MAFIA
        }
        teamCollectionView.delegate = mafiaCollectionViewDelegate
        teamCollectionView.dataSource = mafiaCollectionViewDelegate
        mafiaCollectionViewDelegate!.game = MafiaClient.instance.game
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapped() {
        if isBackShowing {
            UIView.transitionFromView(avatarImageView, toView: roleImageView, duration: 1.0, options: .TransitionFlipFromRight, completion: nil)
            isBackShowing = false
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
        } else {
            UIView.transitionFromView(roleImageView, toView: avatarImageView, duration: 1.0, options: .TransitionFlipFromLeft, completion: nil)
            isBackShowing = true
        }
    }

    @IBAction func onNextButtonClicked(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(GameViewController(), animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
