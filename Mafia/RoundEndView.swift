//
//  RoundEndView.swift
//  Mafia
//
//  Created by Priscilla Lok on 3/19/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class RoundEndView: UIView {

    @IBOutlet weak var nextRoundButton: UIButton!
    @IBOutlet weak var endTitleLabel: UILabel!
    @IBOutlet weak var endDescriptionLabel: UILabel!
    @IBOutlet weak var deadPlayerImage: UIImageView!
    
    //    @IBOutlet weak var roundEndView: UIView!
    //    @IBOutlet weak var endTitleLabel: UILabel!
    //    @IBOutlet weak var endDescriptionLabel: UILabel!
    //    @IBOutlet weak var endRoundContinueButton: UIButton!
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    class func instanceFromNib() -> RoundEndView {
        return UINib(nibName: "RoundEndView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! RoundEndView
    }

}
