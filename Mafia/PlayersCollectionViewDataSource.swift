//
//  PlayersCollectionViewDataSource.swift
//  Mafia
//
//  Created by Charles Yeh on 3/4/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit
import AFNetworking

class PlayersCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate: GameViewControllerDelegate?
    var game: Game?
    var round: Round? {
        didSet {
            if let round = round {
                lynchCounts = countVotes(round.lynchVotes)
                killCounts = countVotes(round.killVotes)
            }
        }
    }
    
    // maps player id to number of votes
    var lynchCounts: [Int: Int]?
    var killCounts: [Int: Int]?
    
    var collectionView: UICollectionView?
    
    init(view: UICollectionView) {
        collectionView = view
    }
    
    func countVotes(votesOrNil: [Int: Int]?) -> [Int: Int] {
        /**
         Converts a mapping of player id to vote target,
         into player id to the number of people voting them.
         */
        
        var count = [Int: Int]()
        if let votes = votesOrNil {
            for voter in votes.keys {
                let votee = votes[voter]!
                count[votee] = (count[votee] ?? 0) + 1
            }
        }
        return count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game?.players.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("playerCell", forIndexPath: indexPath) as! PlayersCollectionViewCell
        
        if let player = game?.players[indexPath.row] {
            // TODO: get avatar
            cell.avatarImageView.image = UIImage(named: player.avatarType)
            
            if player.state == .DEAD {
                cell.nameLabel.text = "DEAD"
            } else {
                cell.nameLabel.text = player.name
            }
            
            cell.voteLabel.text = "\(lynchCounts?[player.id] ?? 0)"
            cell.mafiaLabel.text = "\(killCounts?[player.id] ?? 0)"
            cell.tag = player.id
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)!
        delegate?.selectPlayer(cell.tag)
    }
}
