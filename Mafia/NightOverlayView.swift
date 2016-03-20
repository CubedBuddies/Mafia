//
//  NightOverlayView.swift
//  Mafia
//
//  Created by Priscilla Lok on 3/18/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

@objc protocol NightOverlayViewDelegate {
    optional func nightOverlayView (nightOverlayView: NightOverlayView, voteButtonPressed value: Bool)
}

class NightOverlayView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dialogueLabel: UILabel!
    var view: UIView!
    
    weak var delegate: NightOverlayViewDelegate?
    
    class func instanceFromNib() -> NightOverlayView {
        return UINib(nibName: "NightOverlayView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! NightOverlayView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        voteButton.addTarget(self, action: "voteButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func voteButtonPressed() {
        delegate?.nightOverlayView!(self, voteButtonPressed: voteButton.touchInside)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
