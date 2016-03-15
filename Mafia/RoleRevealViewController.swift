//
//  RoleRevealViewController.swift
//  Mafia
//
//  Created by Priscilla Lok on 3/13/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class RoleRevealViewController: UIViewController {


    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var roleView: UIView!
    var back: UIImageView!
    var front: UIImageView!
    var isBackShowing = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let player = MafiaClient.instance.player
//        if let role = player!.role {
//            switch role {
//            case .TOWNSPERSON:
//                self.front = UIImageView(image: UIImage(named: (MafiaClient.instance.player?.avatarType)!))
//            case .MAFIA:
//                self.front = UIImageView(image: UIImage(named: "mafia"))
//            }
//        }
        let player = MafiaClient.instance.player
        self.front = UIImageView(image: UIImage(named: player!.avatarType))

        self.back = UIImageView(image: UIImage(named: "Character_mystery"))
        back.center = CGPointMake(roleView.center.x, roleView.center.y-40)
        front.center = CGPointMake(roleView.center.x, roleView.center.y-40)
        
        roleView.addSubview(back)
        
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
        if isBackShowing == true {
            UIView.transitionFromView(back, toView: front, duration: 1.0, options: .TransitionFlipFromRight, completion: nil)
            isBackShowing = false
            nextButton.hidden = false
        } else {
            UIView.transitionFromView(front, toView: back, duration: 1.0, options: .TransitionFlipFromLeft, completion: nil)
            isBackShowing = true
        }
    }

    @IBAction func onNextButtonClicked(sender: AnyObject) {
        self.presentViewController(GameViewController(), animated: true, completion: nil)
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