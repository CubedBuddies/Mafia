//
//  PlayersCollectionViewDataSource.swift
//  Mafia
//
//  Created by Charles Yeh on 3/4/16.
//  Copyright © 2016 CubedBuddies. All rights reserved.
//

import UIKit
import AFNetworking

class PlayersCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //var playerStates: [Player]?
    var game: Game?
    var round: Round?
    var collectionView: UICollectionView?
    
    init(view: UICollectionView) {
        collectionView = view
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return game?.players.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("playerCell", forIndexPath: indexPath) as! PlayersCollectionViewCell
        
        if let player = game?.players[indexPath.row] {
            // TODO: get avatar
            //cell.avatarImageView.setImageWithURL(NSURL(string: "")!)
            
            cell.nameLabel.text = player.name
            cell.voteLabel.text = "\(round?.lynchVotes![player.id])"
            cell.mafiaLabel.text = "\(round?.killVotes![player.id])"
            cell.tag = indexPath.row
        }
        
        return cell
    }
}
