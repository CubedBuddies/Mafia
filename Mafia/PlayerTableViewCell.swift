//
//  PlayerTableViewCell.swift
//  Mafia
//
//  Created by Priscilla Lok on 3/6/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

@objc protocol PlayerCellDelegate {
    optional func playerCell (playerCell: PlayerTableViewCell, leaveButtonPressed value:Bool)

}

class PlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var playerNameLabel: UILabel!
    
    weak var delegate: PlayerCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        leaveButton.addTarget(self, action: "leaveButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func leaveButtonPressed() {
        delegate?.playerCell!(self, leaveButtonPressed: leaveButton.touchInside)
        
    }
    

    
    //            MafiaClient.instance.deletePlayer((currPlayer?.id)!,
    //                completion: { (game: Game) -> Void in
    //                    dispatch_async(dispatch_get_main_queue()) {
    //                        MafiaClient.instance.game?.players.removeAtIndex(indexPath.row)
    //                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    ////                        print(game.players.count)
    //                    }
    //                }, failure: { NSLog("Failed to delete player")}
    //            )
    //        }


}
