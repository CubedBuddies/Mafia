//
//  PlayerTableViewCell.swift
//  Mafia
//
//  Created by Priscilla Lok on 3/6/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var playerNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
