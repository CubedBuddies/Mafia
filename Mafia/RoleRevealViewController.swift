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
    var roleImageView: UIImageView!
    var avatarImageView: UIImageView!
    var isBackShowing = true
    
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
            
            print(player.getAvatarUrl())
            self.roleImageView = UIImageView(image: player.getRoleImage())
        }
        
        avatarImageView.center = CGPointMake(roleView.center.x, roleView.center.y-40)
        roleImageView.center = CGPointMake(roleView.center.x, roleView.center.y-40)
        
        roleView.addSubview(avatarImageView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("tapped"))
        singleTap.numberOfTapsRequired = 1
        
        roleView.addGestureRecognizer(singleTap)
        
        nextButton.hidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapped() {
        if isBackShowing {
            UIView.transitionFromView(avatarImageView, toView: roleImageView, duration: 1.0, options: .TransitionFlipFromRight, completion: nil)
            isBackShowing = false
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
