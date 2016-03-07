//
//  PlayersCollectionViewDataSource.swift
//  Mafia
//
//  Created by Charles Yeh on 3/4/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit

class PlayersCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var playerStates: [PlayerState]?
    var collectionView: UICollectionView?
    
    init(view: UICollectionView) {
        collectionView = view
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return playerStates?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("playerCell", forIndexPath: indexPath) as! PlayersCollectionViewCell
        
        if let player = playerStates?[indexPath.row] {
            // TODO: get avatar
//            cell.avatarImageView.setImageWithURL(NSURL(string: "")!)
            cell.nameLabel.text = player.name
            
            cell.voteLabel.text = "\(player.currentVotes)"
            cell.mafiaLabel.text = "\(player.killVotes)"
            
            cell.tag = indexPath.row
        }
        
        return cell
    }
    
    func updatePlayerState(index: Int, playerState: PlayerState) {
        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        collectionView?.reloadItemsAtIndexPaths([indexPath])
    }
}
