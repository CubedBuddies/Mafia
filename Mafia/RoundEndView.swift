//
//  RoundEndView.swift
//  Mafia
//
//  Created by Priscilla Lok on 3/19/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

@objc protocol RoundEndViewDelegate {
    optional func roundEndView(roundEndView: RoundEndView, nextButtonPressed value: Bool)
}

class RoundEndView: UIView {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var descriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var endTitleLabel: UILabel!
    @IBOutlet weak var endDescriptionLabel: UILabel!
    @IBOutlet weak var deadPlayerImage: UIImageView!
    
    weak var delegate: RoundEndViewDelegate?
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nextButton.addTarget(self, action: "nextButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func nextButtonPressed() {
        delegate?.roundEndView!(self, nextButtonPressed: nextButton.touchInside)
    }
    

}
